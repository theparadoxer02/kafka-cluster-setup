# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
source ~/.bashrc
docker rm -f kafka-connect-avro

i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


# bootstrap_server_url=""     # Bootstrap Server links like Server1:9092,Server2:9092,
# schema_registry_url=""      # Schema Registry Url link like Server1:8081,Server2:8081,

# j=0
# for var in "$@"
# do
#     let j=j+1
#     bootstrap_server_url="$bootstrap_server_url"$\Server$j":9092,"
#     schema_registry_url="$schema_registry_url"$\Server$j":8081,"
# done

# echo $bootstrap_server_url
# echo $schema_registry_url

eval SelfIP=$\Server$id

docker run -d \
  --name=kafka-connect-avro \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  --link schema-registry-$id:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$SelfIP:9092 \
  -e CONNECT_GROUP_ID="iotavro" \
  -e CONNECT_CONFIG_STORAGE_TOPIC="iot-avro-config" \
  -e CONNECT_OFFSET_STORAGE_TOPIC="iot-avro-offsets" \
  -e CONNECT_STATUS_STORAGE_TOPIC="iot-avro-status" \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL="$SelfIP:8081" `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL="$SelfIP:8081" \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="0.0.0.0"  \
  -e CONNECT_REST_PORT=8083 \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/\
  -v /tmp/quickstart/file:/tmp/quickstart \
  -v /tmp/quickstart/jars:/etc/kafka-connect/jars \
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:5.0.1


# docker run -d \
#   --name=kafka-connect-avro \
#   --link zoo-1:zookeeper \
#   --link kafka-1:kafka \
#   --link schema-registry-1:schema-registry \
#   -e CONNECT_BOOTSTRAP_SERVERS=10.0.1.70:9092,10.0.1.212:9092,10.0.1.94:9092 `#  Addresses of the Kafka brokers` \
#   -e CONNECT_GROUP_ID="iot-avro" `# Create a Group Id` \
#   -e CONNECT_CONFIG_STORAGE_TOPIC="iot-avro-config" `# First Topic created using Kafka-Topic` \
#   -e CONNECT_OFFSET_STORAGE_TOPIC="iot-avro-offsets" `# Second Topic created using Kafka-Topic` \
#   -e CONNECT_STATUS_STORAGE_TOPIC="iot-avro-status" `# Third Topic created using Kafka-Topic` \
#   -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
#   -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
#   -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
#   -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
#   -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
#   -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=10.0.1.70:9092,10.0.1.212:9092,10.0.1.94:9092 `# Connect Key Schema Registry URL` \
#   -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=10.0.1.70:8081,10.0.1.212:8081,10.0.1.94:8081 `# Connect Value Schema Registry URL` \
#   -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
#   -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
#   -e CONNECT_REST_ADVERTISED_HOST_NAME=10.0.1.70 `# Kafka Connect Rest API Interface` \
#   -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
#   -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
#   -e CONNECT_PLUGIN_PATH=/usr/share/java/\
#   -v /tmp/quickstart/file:/tmp/quickstart \
#   -v /tmp/quickstart/jars:/etc/kafka-connect/jars \
#   -p 8083:8083 \
#   confluent/kafka-connect



# docker run -d \
#   --name=kafka-connect-avro \
#   --link zoo-$1:zookeeper \
#   --link kafka-$id:kafka \
#   --link schema-registry-$id:schema-registry \
#   -e CONNECT_BOOTSTRAP_SERVERS=$bootstrap_server_url `#  Addresses of the Kafka brokers` \
#   -e CONNECT_GROUP_ID="iot-avro" `# Create a Group Id` \
#   -e CONNECT_CONFIG_STORAGE_TOPIC="iot-avro-config" `# First Topic created using Kafka-Topic` \
#   -e CONNECT_OFFSET_STORAGE_TOPIC="iot-avro-offsets" `# Second Topic created using Kafka-Topic` \
#   -e CONNECT_STATUS_STORAGE_TOPIC="iot-avro-status" `# Third Topic created using Kafka-Topic` \
#   -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
#   -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
#   -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
#   -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
#   -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
#   -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=$bootstrap_server_url `# Connect Key Schema Registry URL` \
#   -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=$schema_registry_url `# Connect Value Schema Registry URL` \
#   -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
#   -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
#   -e CONNECT_REST_ADVERTISED_HOST_NAME=$SelfIP `# Kafka Connect Rest API Interface` \
#   -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
#   -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
#   -e CONNECT_PLUGIN_PATH=/usr/share/java/\
#   -p 8083:8083 \
#   confluentinc/cp-kafka-connect:latest



# docker run --link kafka-connect-avro:kaka-connect --name postgres -e POSTGRES_PASSWORD=next_pass -e POSTGRES_USER=next_user -e POSTGRES_DB=nextiot -d postgres



# curl -X POST -H "Content-Type: application/json" \
#   --data '{
#     "name": "nextiot-sink",
#     "config": {
#         "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
#         "connection.url": "jdbc:postgresql://172.17.0.6:5432/nextiot",
#         "connection.user": "next_user",
#         "connection.password": "next_pass",
#         "auto.create": true,
#         "auto.evolve": true,
#         "topics": "nextiot"
#         }
#     }' http://10.0.1.70:8083/connectors
