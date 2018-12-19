docker run -d \
    --name zoo-1 \
    -e zk_id=1 \
    -e zk_server.1=10.5.50.233:2888:3888 \
    -e ZOOKEEPER_CLIENT_PORT=2181 \
    -e ZOOKEEPER_TICK_TIME=2000 \
    -e ZOOKEEPER_SYNC_LIMIT=2 \
    -p 2181:2181 \
    -p 2888:2888 \
    -p 3888:3888 \
    confluentinc/cp-zookeeper:5.0.1

# Kafka
docker run -d \
    --name kafka-1 \
    --link zoo-1:zookeeper \
    -e KAFKA_ZOOKEEPER_CONNECT=10.5.50.233:2181 \
    -e KAFKA_ADVERTISED_HOST_NAME=10.5.50.233 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://10.5.50.233:9092 \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    -p 9092:9092 \
    confluentinc/cp-kafka:5.0.1




# Schema-Registry
docker run -d \
--name=schema-registry-1 \
--link zoo-1:zookeeper \
--link kafka-1:kafka \
-e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=10.0.1.70:2181,10.0.1.212:2181,10.0.1.94:2181 \
-e SCHEMA_REGISTRY_HOST_NAME=10.0.1.70 \
-p 8081:8081 \
confluent/schema-registry


docker exec -it kafka-1 sh -c " \
  kafka-topics --create --topic iot-avro-config --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 10.5.50.233:2181 \
  && kafka-topics --create --topic iot-avro-offsets --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 10.5.50.233:2181 \
  && kafka-topics --create --topic iot-avro-status --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 10.5.50.233:2181 \
  && kafka-topics --create --topic nextiot --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 10.5.50.233:2181"
 


# Kafka connect
docker run -d \
  --name=kafka-connect-avro \
  --link zoo-1:zookeeper \
  --link kafka-1:kafka \
  --link schema-registry-1:schema-registry \
  --link kafka-rest:kafka-rest \
  -e CONNECT_BOOTSTRAP_SERVERS=10.5.50.233:9092 \
  -e CONNECT_GROUP_ID="iotavro" \
  -e CONNECT_CONFIG_STORAGE_TOPIC="iot-avro-config" \
  -e CONNECT_OFFSET_STORAGE_TOPIC="iot-avro-offsets" \
  -e CONNECT_STATUS_STORAGE_TOPIC="iot-avro-status" \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
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

# Kafka Rest
docker run -d \
    --link zoo-1:zookeeper \
    --link kafka-1:kafka \
    --name=kafka-rest \
    -e KAFKA_REST_ZOOKEEPER_CONNECT=10.5.50.233:2181 \
    -e KAFKA_REST_LISTENERS=http://0.0.0.0:8082 \
    -e KAFKA_REST_SCHEMA_REGISTRY_URL=http://10.5.50.233:8081 \
    -e KAFKA_REST_HOST_NAME=kafka-rest \
    -p 8082:8082 \
    confluentinc/cp-kafka-rest:5.0.1


# kafka-avro-console-consumer   --bootstrap-server 10.5.50.233:2181 --topic bar   --property schema.registry.url=http://10.5.50.233:8081   --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'


# # Register The schema using
# python register_schema.py http://10.5.50.233:8082 nextiot 




docker run --link kafka-connect-avro:kaka-connect --name postgres -e POSTGRES_PASSWORD=next_pass -e POSTGRES_USER=next_user -e POSTGRES_DB=nextiot -d postgres


# Add Connector to the Kafka Connect
curl -X POST -H "Content-Type: application/json" \
  --data '{
    "name": "nextiot-sink",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "connection.url": "jdbc:postgresql://10.0.1.233:5432/nextiot",
        "connection.user": "next_user",
        "connection.password": "next_pass",
        "auto.create": true,
        "auto.evolve": true,
        "topics": "nextiot"
        }
    }' http://10.0.1.70:8083/connectors



{
	"type": "record",
	"name": "User",
	"fields": [
		{"name": "deviceid", "type": "string"},
		{"name": "latitude",  "type": ["float", "null"]},
		{"name": "longitude", "type": ["float", "null"]}
	]
}


# kafka-avro-console-producer   --broker-list 10.5.50.233:9092 --topic bar   --property schema.registry.url=http://10.5.50.233:8081   --property value.schema='{"type": "record","name": "User","fields": [{"name": "deviceid", "type": "string"},{"name": "latitude",  "type": ["float", "null"]},{"name": "longitude", "type": ["float", "null"]}]}'

# kafka-avro-console-consumer   --bootstrap-server 10.5.50.233:9092 --topic bar   --property schema.registry.url=http://10.5.50.233:8081


# {"deviceid":"010098", "latitude": { "float": 22.34 }, "longitude": { "float": 334.4}}



10.0.1.70:9092,10.0.1.212:9092,10.0.1.94:9092