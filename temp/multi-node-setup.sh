#server1=$(hostname -I)

#################################################################################################
Note: Server1 is is the ip address of the node in which the Script is running.
#################################################################################################

server1=0.0.0.0
Server1=192.168.10.130
Server2=192.168.10.132
Server3=192.168.10.133
# Node id that is defined manually


# Setup Zookeeper On multi node first

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


## Kafka on Node1 / Host1:
docker run -d \
    --name kafka-$id \
    --link zoo-1:zookeeper \
    -e KAFKA_BROKER_ID=$id `# Kafka Broker Id number` \
    -e KAFKA_ZOOKEEPER_CONNECT=$Server1:2181,$Server2:2181,$Server3:2181 `# Zookeeper all Servers Address` \
    -e KAFKA_ADVERTISED_HOST_NAME=$Server1 `# Self server Public IP` \
    -e KAFKA_ADVERTISED_PORT=9092 `# Kafka Service port` \
    -p 9092:9092 \
    confluent/kafka

## Schema Registry on Node1/Host1
docker run -d \
  --name=schema-registry-1 `# Name of the Container Image` \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=10.0.1.70 \
  -e SCHEMA_REGISTRY_HOST_NAME="0.0.0.0" `# Hostname of schema Registry` \
  confluent/schema-registry


# Create 3 Topics in 1st Server
if [ $id = 1 ]
then 
  docker exec -it kafka bash

  kafka-topics --create --topic quickstart-avro-offsets --partitions 3 --replication-factor 3 --if-not-exists --zookeeper $Server1:2181,$Server2:2181,$Server3:2181
  kafka-topics --create --topic quickstart-avro-config --partitions 3 --replication-factor 3 --if-not-exists --zookeeper $Server1:2181,$Server2:2181,$Server3:2181
  kafka-topics --create --topic quickstart-avro-status --partitions 3 --replication-factor 3 --if-not-exists --zookeeper $Server1:2181,$Server2:2181,$Server3:2181
  exit
fi

docker run \
  --name=kafka-connect-avro \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  --link schema-registry-2:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$Server1:9092,$Server2:9092,$Server3:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
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
  -e CONNECT_REST_ADVERTISED_HOST_NAME=$Server1 `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/\
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest






## Zookeeper on Node2 / Host2:
docker run -d \
    --name zoo-$id \
    -e zk_id=2 `# Zookeeper ID` \
    -e zk_server.1=$Server1:2888:3888 `# Server1 Public IP` \
    -e zk_server.2=$Server2:2888:3888 `# Server2 Internal IP` \
    -e zk_server.3=$Server3:2888:3888 `# Server3 Public IP` \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    confluent/zookeeper



docker run \
  --name=kafka-connect-avro \
  --link zoo-1:zookeeper \
  --link kafka-1:kafka \
  --link schema-registry-1:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$Server1:9092,$Server2:9092,$Server2:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
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
  -e CONNECT_REST_ADVERTISED_HOST_NAME=$Server1 `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/kafka-connect-jdbc/ \
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest  



## Kafka on Node2 / Host2:
docker run \
    --name kafka-$id \
    -e KAFKA_BROKER_ID=2 `# Kafka Broker Id number` \
    -e KAFKA_ZOOKEEPER_CONNECT=$Server1:2181,$Server2:2181,$Server3:2181 `# Zookeeper all Servers Address` \
    -e KAFKA_ADVERTISED_HOST_NAME=$Server1 `# Self server Public IP` \
    -e KAFKA_ADVERTISED_PORT=9092 `# Kafka Service port` \
    -p 9092:9092 \
    confluent/kafka

## Schema Registry on Node2/Host2
docker run -d \
  --link zoo-2:zookeeper \
  --link kafka-2:kafka \
  --name=schema-registry-2 `# Name of the Container Image` \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$Server1:2181,$Server2:2181,$Server3:2181 \
  -e SCHEMA_REGISTRY_HOST_NAME=$Server1 `# Hostname of schema Registry` \
  confluent/schema-registry



docker run -d \
  --name=schema-registry-2 `# Name of the Container Image` \
  --link zoo-2:zookeeper \
  --link kafka-2:kafka \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$Server1:2181,$Server2:2181,$Server3:2181 \
  -e SCHEMA_REGISTRY_HOST_NAME=$Server1 `# Hostname of schema Registry` \
  confluent/schema-registry


## Zookeeper on Node3 / Host3:
docker run -d \
    --name zoo-3 \
    -e zk_id=3 \
    -e zk_server.1=$Server1:2888:3888 `# Server1 Public IP` \
    -e zk_server.2=$Server2:2888:3888 `# Server2 Public IP` \
    -e zk_server.3=$Server3:2888:3888 `# Server3 Internal IP` \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    confluent/zookeeper

## Kafka on Node3 / Host3:
docker run \
    --name kafka-3 \
    -e KAFKA_BROKER_ID=3 \
    -e KAFKA_ZOOKEEPER_CONNECT=$Server1:2181,$Server2:2181,$Server3:2181  `# Zookeeper all Servers Address` \
    -e KAFKA_ADVERTISED_HOST_NAME=$Server1 `# Self server Public IP` \
    -e KAFKA_ADVERTISED_PORT=9092 `# Kafka Service port` \
    -p 9092:9092 \
    confluent/kafka


## Schema Registry on Node3/Host3
docker run -d \
  --link zoo-3:zookeeper \
  --link kafka-3:kafka \
  --name=schema-registry-3 `# Name of the Container Image` \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$Server1:2181,$Server2:2181,$Server3:2181 \
  -e SCHEMA_REGISTRY_HOST_NAME=$Server1 `# Hostname of schema Registry` \
  confluent/schema-registry


## Kafka Connect AVRO on Node1/Host1
docker run \
  --name=kafka-connect-avro \
  --link zoo-1:zookeeper \
  --link kafka-1:kafka \
  --link schema-registry-1:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$Server1:9092,$Server2:9092,$Server2:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
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
  -e CONNECT_REST_ADVERTISED_HOST_NAME=$Server1 `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/kafka-connect-jdbc/ \
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest


# Kafka Connect on Node2/Host2
docker run \
  --name=kafka-connect-avro \
  --link zoo-2:zookeeper \
  --link kafka-2:kafka \
  --link schema-registry-2:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=10.5.48.223:9092,10.5.48.152:9092,10.5.48.231:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
  -e CONNECT_GROUP_ID="quickstart-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=http://0.0.0.0:8081,http://10.5.48.223:8081,http://10.5.48.231:8081 `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=http://0.0.0.0:8081,http://10.5.48.223:8081,http://10.5.48.231:8081 `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="10.5.48.152" `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/\
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest


# Kafka Connect on Node3/Host3
docker run \
  --name=kafka-connect-avro \
  --link zoo-3:zookeeper \
  --link kafka-3:kafka \
  --link schema-registry-3:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=10.5.48.223:9092,10.5.48.152:9092,10.5.48.231:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
  -e CONNECT_GROUP_ID="quickstart-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=http://0.0.0.0:8081,http://10.5.48.223:8081,http://10.5.48.152:8081 `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=http://0.0.0.0:8081,http://10.5.48.223:8081,http://10.5.48.152:8081 `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="10.5.48.231" `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/ \
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest





# For Rest Proxy Setup
docker run \
    --name rest1 \
    -e REST_PROXY_ID=1 \
    -e RP_ZOOKEEPER_CONNECT=10.5.48.223:2181,10.5.48.152:2181,10.5.48.231:2181 \
    -p 8082:8082 \
    confluent/rest-proxy






kafka-topics --create --topic quickstart-avro-offsets --partitions 3 --replication-factor 3 --if-not-exists --zookeeper 10.5.48.223:2181,10.5.48.152:2181,10.5.48.231:2181


kafka-topics --create --topic quickstart-avro-config --partitions 3 --replication-factor 3 --if-not-exists --zookeeper 10.5.48.223:2181,10.5.48.152:2181,10.5.48.231:2181

kafka-topics --create --topic quickstart-avro-status --partitions 3 --replication-factor 3 --if-not-exists --zookeeper 10.5.48.223:2181,10.5.48.152:2181,10.5.48.231:2181


kafka-topics --describe --zookeeper 10.5.48.223:2181,10.5.48.152:2181,10.5.48.231:2181



curl -X POST \
  -H "Content-Type: application/json" \
  --data '{ "name": "quickstart-jdbc-source", "config": { "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector", "tasks.max": 1, "connection.url": "jdbc:mysql://10.5.50.95:3306/connect_test?user=root&password=root", "mode": "incrementing", "incrementing.column.name": "id", "timestamp.column.name": "modified", "topic.prefix": "quickstart-jdbc-", "poll.interval.ms": 1000 } }' \
  http://10.5.48.223:8083/connectors


curl -X POST -H "Content-Type: application/json" \
   --data '{
       "name": "quickstart-avro-file-sink4", 
       "config": {
         "connector.class":"io.confluent.connect.jdbc.JdbcSinkConnector", 
         "tasks.max":"1", "topics":"quickstart-jdbc-test",
         "connection.url": "jdbc:postgres://10.5.50.95:5432/kafka_test",
         "connection.user": "kafka_user",
         "connection.password":"password"
         }
       }' \
   http://10.5.48.223:8083/connectors





docker run \
  --name=kafka-connect-avro \
  --link zoo-1:zookeeper \
  --link kafka-1:kafka \
  --link schema-registry-1:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=10.5.50.226:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
  -e CONNECT_GROUP_ID="iot-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="iot-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="iot-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="iot-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=http://10.5.50.226:8081 `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=http://10.5.50.226:8081  `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="10.5.50.226:8081" `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/ \
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest