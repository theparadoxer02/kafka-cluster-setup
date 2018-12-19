############################################################################################
#   Install Docker in Centos 
############################################################################################

# Install dependencied for Docker
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

# Add Docker Repository
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Instll Docker
sudo yum-config-manager --enable docker-ce-edge
sudo yum-config-manager --enable docker-ce-test
sudo yum install docker-ce
sudo systemctl start docker
sudo usermod -aG docker $USER

###########################################################################################
# Firewall Settings
###########################################################################################

# Open firewall port 9092
sudo firewall-cmd \
  --zone=public \
  --add-port=9092/tcp \
  --add-port=2182/tcp \
  --add-port=3888/tcp \
  --add-port=2182/tcp \
  --permanent

# Reload Firewall
sudo firewall-cmd --reload

###########################################################################################

Server1=10.5.48.138
Server2=10.5.48.48
Server3=10.5.48.208

SelfIP=$(hostname -I | cut -d" " -f 1)


# Setup Zookeeper On multi node first
eval Server$id=0.0.0.0

## Zookeeper Node1 / Host1:
docker run -d \
    --name zoo-$id \
    -e zk_id=$id `# Zookeeper ID` \
    -e zk_server.1=$Server1:2888:3888 `# Zookeeper 1 node` \
    -e zk_server.2=$Server2:2888:3888 `# Zookeeper 2 node` \
    -e zk_server.3=$Server3:2888:3888 `# Zookeeper 3 node` \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    confluent/zookeeper

eval Server$id=$(hostname -I | cut -d" " -f 1)


wait 10

## Kafka on Node1 / Host1:
docker run -d \
    --name kafka-1 \
    --link zoo-1:zookeeper \
    -e KAFKA_BROKER_ID=1 `# Kafka Broker Id number` \
    -e KAFKA_ZOOKEEPER_CONNECT=172.31.0.114:2181 \
    -e KAFKA_ADVERTISED_HOST_NAME=3.0.209.191 `# Self server Public IP` \
    -e KAFKA_ADVERTISED_PORT=9092 `# Kafka Service port` \
    -p 9092:9092 \
    confluent/kafka


wait 10

## Schema Registry on Node1/Host1
docker run -d \
  --name=schema-registry-$id `# Name of the Container Image` \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$Server1:2181,$Server2:2181,$Server3:2181 \
  -e SCHEMA_REGISTRY_HOST_NAME=$SelfIP `# Hostname of schema Registry` \
  confluent/schema-registry


# # Create 3 Topics in Anyone of the Servers, say 1st Server
if [ $id == 1 ]
then 
  docker exec -it kafka-$id sh -c " \
  kafka-topics --create --topic quickstart-avro-offsets --partitions 3 --replication-factor 3 --if-not-exists --zookeeper $Server1:2181,$Server2:2181,$Server3:2181 \
  && kafka-topics --create --topic quickstart-avro-config --partitions 3 --replication-factor 3 --if-not-exists --zookeeper $Server1:2181,$Server2:2181,$Server3:2181 \
  && kafka-topics --create --topic quickstart-avro-status --partitions 3 --replication-factor 3 --if-not-exists --zookeeper $Server1:2181,$Server2:2181,$Server3:2181"
else
    echo "Topic not created"
fi

# Download the JDBC Driver for Postgres
mkdir -p /usr/share/java/kafka-connect-jdbc
wget sudo wget https://jdbc.postgresql.org/download/postgresql-42.2.5.jar -P /usr/share/java/kafka-connect-jdbc


docker run -d \
  --name=kafka-connect-avro \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  --link schema-registry-$id:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$Server1:9092,$Server2:9092,$Server3:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_GROUP_ID="quickstart-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=http://$Server1:8081,http://$Server2:8081,http://$Server3:8081 `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=http://$Server1:8081,http://$Server2:8081,http://$Server3:8081 `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME=$SelfIP `# Kafka Connect Rest API Interface` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/\
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest

# Create the Sink connector
curl -X POST -H "Content-Type: application/json" \
   --data '{
       "name": "quickstart-avro-file-sink",
       "config": {
         "connector.class":"io.confluent.connect.jdbc.JdbcSinkConnector", 
         "tasks.max":"1", "topics":"quickstart-jdbc-test",
         "connection.url": "jdbc:postgresql://10.5.50.95:5432/kafka_test",
         "connection.user": "kafka_user",
         "connection.password":"password"
         }
       }' \
   http://$SelfIP:8083/connectors