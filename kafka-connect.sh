# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


bootstrap_server_url=""     # Bootstrap Server links like Server1:9092,Server2:9092,
schema_registry_url=""      # Schema Registry Url link like Server1:8081,Server2:8081,

j=0
for var in "$@"
do
    let j=j+1
    bootstrap_server_url="$bootstrap_server_url"$\Server$j":9092,"
    schema_registry_url="$schema_registry_url"$\Server$j":8081,"
done

# echo $bootstrap_server_url
# echo $schema_registry_url

eval SelfIP=$\Server$id


docker run -d \
  --name=kafka-connect-avro \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  --link schema-registry-$id:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$bootstrap_server_url `#  Addresses of the Kafka brokers` \
  -e CONNECT_GROUP_ID="quickstart-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=$bootstrap_server_url `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=$schema_registry_url `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME=$SelfIP `# Kafka Connect Rest API Interface` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/\
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest