echo $#

# zk_server_list_arg=""
# i=0
# for var in "$@"
# do
#     echo "$var"
#     let i=i+1
#     eval Server$i=$var
# done

# eval Server$id=0.0.0.0
# echo Server$id
# j=0
# for var in "$@"
# do
#     let j=j+1
#     zk_server_list_arg="$zk_server_list_arg -e zk_server.$j="$\Server$j":2888:3888"
# done

# echo $zk_server_list_arg

# t="docker run -d \
#     --name zoo-$id \
#     -e zk_id=$id `# Zookeeper ID` \
#     $zk_server_list_arg \
#     -p 2181:2181 \
#     -p 2888:2888 \
#     -p 3888:3888 \
#     confluent/zookeeper"

# eval $t

# kafka_server_list=""
# for var in "$@"
# do
#     let j=j+1
#     kafka_server_list="$kafka_server_list,"$\Server$j":2181"
# done

# echo $kafka_server_list


# i=0
# for var in "$@"
# do
#     echo "$var"
#     let i=i+1
#     eval Server$i=$var
# done


# kafka_server_link=""
# kafka_server_list=""

# j=0
# for var in "$@"
# do
#     let j=j+1
#     kafka_server_link="$kafka_server_link"$\Server$j":2181,"
#     kafka_server_list="$kafka_server_list -e Server$j="$\Server$j""
# done

# echo $kafka_server_list
# echo $kafka_server_list

# eval SelfIP=$(hostname -I | cut -d" " -f 1)

# ## Kafka on Node1 / Host1:
# t="docker run -d \
#     --name kafka-$id \
#     --link zoo-$id:zookeeper \
#     -e KAFKA_BROKER_ID=$id `# Kafka Broker Id number` \
#     -e KAFKA_ZOOKEEPER_CONNECT=$kafka_server_link `# Zookeeper all Servers Address` \
#     $kafka_server_list \
#     -e KAFKA_ADVERTISED_HOST_NAME=$SelfIP  `# Self server Public IP` \
#     -e KAFKA_ADVERTISED_PORT=9092 `# Kafka Service port` \
#     -p 9092:9092 \
#     confluent/kafka"
# echo $t
# eval $t


##  Schema Registry url


# i=0
# for var in "$@"
# do
#     echo "$var"
#     let i=i+1
#     eval Server$i=$var
# done


# kafka_connection_url=""

# j=0
# for var in "$@"
# do
#     let j=j+1
#     kafka_connection_url="$kafka_connection_url"$\Server$j":2181,"
# done

# echo $kafka_connection_url

# eval SelfIP=$(hostname -I | cut -d" " -f 1)


# ## Schema Registry on Node1/Host1
# t="docker run -d \
#   --name=schema-registry-$id `# Name of the Container Image` \
#   --link zoo-$id:zookeeper \
#   --link kafka-$id:kafka \
#   -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$kafka_connection_url \
#   -e SCHEMA_REGISTRY_HOST_NAME=$SelfIP `# Hostname of schema Registry` \
#   confluent/schema-registry"

# eval $t


# KAFKA CONNECT

i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


bootstrap_server_url=""
schema_registry_url=""

j=0
for var in "$@"
do
    let j=j+1
    bootstrap_server_url="$bootstrap_server_url"$\Server$j":9092,"
    schema_registry_url="$schema_registry_url"$\Server$j":8081,"
done

echo $bootstrap_server_url
echo $schema_registry_url

SelfIP=$(hostname -I | cut -d" " -f 1)


docker run -d \
  --name=kafka-connect-avro \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  --link schema-registry-$id:schema-registry \
  -e CONNECT_BOOTSTRAP_SERVERS=$bootstrap_server_url`#  Addresses of the Kafka brokers` \
  -e CONNECT_GROUP_ID="quickstart-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=3 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=3 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL=$schema_registry_url `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL=$schema_registry_url `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME=$SelfIP `# Kafka Connect Rest API Interface` \
  -e CONNECT_REST_PORT=8083 `# Kafka connect REST API PORT` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/\
  -p 8083:8083 \
  confluentinc/cp-kafka-connect:latest
