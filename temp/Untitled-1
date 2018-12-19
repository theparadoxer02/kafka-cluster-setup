kafka-topics --create --topic foo --partitions 1 --replication-factor 1 \
--if-not-exists --zookeeper 10.5.50.233:2181


bash -c "seq 42 | kafka-console-producer --request-required-acks 1 \
--broker-list 10.5.50.233:9092 --topic foo && echo 'Produced 42 messages.'"


kafka-console-consumer --bootstrap-server 10.5.50.233:9092 --topic foo --from-beginning --max-messages 42

kafka-avro-console-consumer \
  --broker-list 10.5.50.233:9092 --topic bar \
  --property schema.registry.url=http://10.5.50.233:8081 \
  --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'


curl -X POST -H "Content-Type: application/vnd.kafka.v1+json" \
  --data '{"name": "my_consumer_instance", "format": "avro", "auto.offset.reset": "smallest"}' \
  http://10.5.50.233:8082/consumers/my_avro_consumer


curl -X GET -H "Accept: application/vnd.kafka.avro.v1+json" \
  http://10.5.50.233:8082/consumers/my_avro_consumer/instances/my_consumer_instance/topics/bar



docker run -d \
--name control-center \
--link zoo-1:zookeeper \
--link kafka-1:kafka \
--ulimit nofile=16384:16384 \
-p 9021:9021 \
-v /tmp/control-center/data:/var/lib/confluent-control-center \
-e CONTROL_CENTER_ZOOKEEPER_CONNECT=10.5.50.233:2181 \
-e CONTROL_CENTER_BOOTSTRAP_SERVERS=10.5.50.233:9092 \
-e CONTROL_CENTER_REPLICATION_FACTOR=1 \
-e CONTROL_CENTER_MONITORING_INTERCEPTOR_TOPIC_PARTITIONS=1 \
-e CONTROL_CENTER_INTERNAL_TOPICS_PARTITIONS=1 \
-e CONTROL_CENTER_STREAMS_NUM_STREAM_THREADS=2 \
-e CONTROL_CENTER_CONNECT_CLUSTER=http://10.5.50.233:8082 \
confluentinc/cp-enterprise-control-center:5.0.1

kafka-topics --create --topic c3-test --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 10.540.233:2181


while true;
do
  docker run \
    --link zoo-1:zookeeper \
    --link kafka-1:kafka \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.0.1.jar \
    confluentinc/cp-kafka-connect:5.0.1 \
    bash -c 'seq 10000 | kafka-console-producer --request-required-acks 1 --broker-list 10.5.50.233:9092 --topic c3-test --producer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringProducerInterceptor --producer-property acks=1 && echo "Produced 10000 messages."'
    sleep 10;
done


  OFFSET=0
  while true;
do
  docker run \
    --net=confluent \
    --rm \
    -e CLASSPATH=/usr/share/java/monitoring-interceptors/monitoring-interceptors-5.0.1.jar \
    confluentinc/cp-kafka-connect:5.0.1 \
    bash -c 'kafka-console-consumer --consumer-property group.id=qs-consumer --consumer-property interceptor.classes=io.confluent.monitoring.clients.interceptor.MonitoringConsumerInterceptor --bootstrap-server 10.5.50.233:9092 --topic c3-test --offset '$OFFSET' --partition 0 --max-messages=1000'
  sleep 1;
  let OFFSET=OFFSET+1000
done



docker exec kafka-connect-avro curl -s -X POST \
-H "Content-Type: application/json" \
--data '{"name": "quickstart-file-source", "config": {"connector.class":"org.apache.kafka.connect.file.FileStreamSourceConnector", "tasks.max":"1", "topic":"quickstart-data", "file": "/tmp/quickstart/file/input.txt"}}' \
http://10.5.50.233:8083/connectors



kafka-console-consumer --bootstrap-server 10.5.50.233:9092 --topic \
quickstart-data --from-beginning --max-messages 10



kafka-avro-console-consumer   --bootstrap-server 10.5.50.233:9092 --topic bar   --property schema.registry.url=http://10.5.50.233:8081


kafka-avro-console-producer   --broker-list 10.0.0.1:9092 --topic nextiot   --property schema.registry.url=http://10.5.50.233:8081   --property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}'


{"deviceid":"010001","latitude": { "float": 32.34"},"longitude: {float :23.33}}
