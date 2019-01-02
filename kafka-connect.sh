# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
source ~/.bashrc
docker rm -f kafka-connect-avro-$id

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
  --restart=on-failure:10 `#try restarting container for 10 times` \
  --name=kafka-connect-avro-$id \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  --link schema-registry-$id:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$SelfIP:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=8083 `# Kafka Connect Rest Port` \
  -e CONNECT_GROUP_ID="iotavro" `# Kafka Connectors Group ID` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="iot-avro-config" `# config Topic required to run Kafka-Connect` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="iot-avro-offsets" `# offsets Topic required to run Kafka-Connect` \
  -e CONNECT_STATUS_STORAGE_TOPIC="iot-avro-status" `# status Topic required to run Kafka-Connect` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3  `# config topic Replication Factor when Kafka Connects automatically creates this topic` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3  `# offset topic Replication Factor when Kafka Connects automatically creates this topic` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3  `# status topic Replication Factor when Kafka Connects automatically creates this topic` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" `# Data Format Converter for Key to and from outside Kafka connect` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `# Data Format Converter for Value to and from outside Kafka connect` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://$SelfIP:8081" `# Schema Registry URL for key` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://$SelfIP:8081" `# Schema Registry URL for Value` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="0.0.0.0" `# Kafka Connect Rest API Interface` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/ `# Java Plugin Path required to run Kafka connect` \
  -v /tmp/quickstart/file:/tmp/quickstart \
  -v /tmp/quickstart/jars:/etc/kafka-connect/jars \
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:5.0.1
