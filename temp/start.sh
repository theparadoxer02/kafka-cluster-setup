docker-machine create --driver virtualbox --virtualbox-memory 6000 confluent

docker-machine env confluent

docker network create confluent

docker run -d \
    --net=confluent \
    --name=zookeeper \
    -e ZOOKEEPER_CLIENT_PORT=2181 \
    confluentinc/cp-zookeeper:5.0.0


    # docker logs zookeeper

# KAFKA SETUP
docker run -d \
    --net=confluent \
    --name=kafka \
    -e KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:9092 \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
    confluentinc/cp-kafka:5.0.0

# Step 3. Create a Topic and Produce Data

docker run \
  --net=confluent \
  --rm confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic foo --partitions 1 --replication-factor 1 \
  --if-not-exists --zookeeper zookeeper:2181


docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-topics --describe --
  

docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  bash -c "seq 42 | kafka-console-producer --request-required-acks 1 \
  --broker-list kafka:9092 --topic foo && echo 'Produced 42 messages.'"

docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-console-consumer --bootstrap-server kafka:9092 --topic foo --from-beginning --max-messages 42


# Step 4: Start Schema Registry

docker run -d \
  --net=confluent \
  --name=schema-registry \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=zookeeper:2181 \
  -e SCHEMA_REGISTRY_HOST_NAME=schema-registry \
  -e SCHEMA_REGISTRY_LISTENERS=http://0.0.0.0:8081 \
  confluentinc/cp-schema-registry:5.0.0

# docker run -it --net=confluent --rm confluentinc/cp-schema-registry:5.0.0 bash

# /usr/bin/kafka-avro-console-producer \
#   --broker-list kafka:9092 --topic bar \
#   --property schema.registry.url=http://schema-registry:8081 \
#   --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'

# {"f1": "value1"}
# {"f1": "value2"}
# {"f1": "value3"}

# exit

# Step 5: Start REST Proxy

docker run -d \
  --net=confluent \
  --name=kafka-rest \
  -e KAFKA_REST_ZOOKEEPER_CONNECT=zookeeper:2181 \
  -e KAFKA_REST_LISTENERS=http://0.0.0.0:8082 \
  -e KAFKA_REST_SCHEMA_REGISTRY_URL=http://schema-registry:8081 \
  -e KAFKA_REST_HOST_NAME=kafka-rest \
  confluentinc/cp-kafka-rest:5.0.0

# docker run -it --net=confluent --rm confluentinc/cp-schema-registry:5.0.0 bash

# curl -X POST -H "Content-Type: application/vnd.kafka.v1+json" \
#   --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "smallest"}' \
#   http://kafka-rest:8082/consumers/my_avro_consumer

# curl -X GET -H "Accept: application/vnd.kafka.avro.v1+json" \
#   http://kafka-rest:8082/consumers/my_avro_consumer/instances/my_consumer_instance/topics/bar

# exit


# Step 6: Start Control Center

docker run -d \
  --name=control-center \
  --net=confluent \
  --ulimit nofile=16384:16384 \
  -p 9021:9021 \
  -v /tmp/control-center/data:/var/lib/confluent-control-center \
  -e CONTROL_CENTER_ZOOKEEPER_CONNECT=zookeeper:2181 \
  -e CONTROL_CENTER_BOOTSTRAP_SERVERS=kafka:9092 \
  -e CONTROL_CENTER_REPLICATION_FACTOR=1 \
  -e CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_PARTITIONS=1 \
  -e CONTROL_CENTER_INTERNAL_TOPICS_PARTITIONS=1 \
  -e CONTROL_CENTER_STREAMS_NUM_STREAM_THREADS=2 \
  -e CONTROL_CENTER_CONNECT_CLUSTER=http://kafka-connect:8082 \
  confluentinc/cp-enterprise-control-center:5.0.0


docker-machine ip confluent

docker run \
  --net=confluent \
  --rm confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic c3-test --partitions 1 --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

while true;
do
  docker run \
    --net=confluent \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.0.0.jar \
    confluentinc/cp-kafka-connect:5.0.0 \
    bash -c 'seq 10000 | kafka-console-producer --request-required-acks 1 --broker-list kafka:9092 --topic c3-test --producer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor --producer-property acks=1 && echo "Produced 10000 messages."'
    sleep 10;
done

OFFSET=0
while true;
do
  docker run \
    --net=confluent \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.0.0.jar \
    confluentinc/cp-kafka-connect:5.0.0 \
    bash -c 'kafka-console-consumer --consumer-property group.id=qs-consumer --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor --bootstrap-server kafka:9092 --topic c3-test --offset '$OFFSET' --partition 0 --max-messages=1000'
  sleep 1;
  let OFFSET=OFFSET+1000
done

# Step 7: Start Kafka Connect

docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic quickstart-offsets --partitions 1 \
  --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181

docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-topics --create --topic quickstart-data --partitions 1 \
  --replication-factor 1 --if-not-exists --zookeeper zookeeper:2181


docker run \
   --net=confluent \
   --rm \
   confluentinc/cp-kafka:5.0.0 \
   kafka-topics --describe --zookeeper zookeeper:2181

docker run -d \
  --name=kafka-connect \
  --net=confluent \
  -e CONNECT_PRODUCER_INTERCEPTOR_CLASSES=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor \
  -e CONNECT_CONSUMER_INTERCEPTOR_CLASSES=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor \
  -e CONNECT_BOOTSTRAP_SERVERS=kafka:9092 \
  -e CONNECT_REST_PORT=8082 \
  -e CONNECT_GROUP_ID="quickstart" \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-config" \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-offsets" \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-status" \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 \
  -e CONNECT_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="kafka-connect" \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG \
  -e CONNECT_PLUGIN_PATH=/usr/share/java \
  -e CONNECT_REST_HOST_NAME="kafka-connect" \
  -v /tmp/quickstart/file:/tmp/quickstart \
  confluentinc/cp-kafka-connect:5.0.0


docker exec kafka-connect mkdir -p /tmp/quickstart/file

docker exec kafka-connect sh -c 'seq 1000 > /tmp/quickstart/file/input.txt'

docker exec kafka-connect curl -s -X POST \
  -H "Content-Type: application/json" \
  --data '{"name": "quickstart-file-source", "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSourceConnector", "tasks.max":"1", "topic":"quickstart-data", "file": "/tmp/quickstart/file/input.txt"}}' \
  http://kafka-connect:8082/connectors

docker exec kafka-connect curl -s -X GET http://kafka-connect:8082/connectors/quickstart-file-source/status

docker run \
  --net=confluent \
  --rm \
  confluentinc/cp-kafka:5.0.0 \
  kafka-console-consumer --bootstrap-server kafka:9092 --topic \
  quickstart-data --from-beginning --max-messages 10

docker exec kafka-connect curl -X POST -H "Content-Type: application/json" \
    --data '{"name": "quickstart-file-sink", \
    "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSinkConnector", "tasks.max":"1", \
    "topics":"quickstart-data", "file": "/tmp/quickstart/file/output.txt"}}' \
    http://kafka-connect:8082/connectors


docker exec kafka-connect curl -s -X GET http://kafka-connect:8082/connectors/quickstart-file-sink/status

docker exec kafka-connect cat /tmp/quickstart/file/output.txt
