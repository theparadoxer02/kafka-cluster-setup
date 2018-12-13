docker run -d \
--link zoo-$id:zookeeper \
--link kafka-$id:kafka \
--name=kafka-rest \
-e KAFKA_REST_ZOOKEEPER_CONNECT=zookeeper:2181 \
-e KAFKA_REST_LISTENERS=http://0.0.0.0:8082 \
-e KAFKA_REST_SCHEMA_REGISTRY_URL=http://schema-registry:8081 \
-e KAFKA_REST_HOST_NAME=kafka-rest \
-p 8082:8082 \
confluentinc/cp-kafka-rest:5.0.1
