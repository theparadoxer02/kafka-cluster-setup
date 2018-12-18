# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


kafka_connection_url=""  # Server links like Server1:2181,Server2:2181,

j=0
for var in "$@"
do
    let j=j+1
    kafka_connection_url="$kafka_connection_url"$\Server$j":2181,"
done

# echo $kafka_connection_url

eval SelfIP=$\Server$id


## Schema Registry on Node1/Host1
t="docker run -d \
  --name=schema-registry-$id `# Name of the Container Image` \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$kafka_connection_url \
  -e SCHEMA_REGISTRY_HOST_NAME="localhost" `# Hostname of schema Registry` \
  -p 8081:8081 \
  confluent/schema-registry"

eval $t



# docker run -d \
#   --name=schema-registry-1 `# Name of the Container Image` \
#   --link zoo-1:zookeeper \
#   --link kafka-1:kafka \
#   -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL="10.5.50.230:2181" \
#   -e SCHEMA_REGISTRY_HOST_NAME="localhost" \
#   -e SCHEMA_REGISTRY_DEBUG=TRUE \
#   -p 8081:8081 \
#   confluent/schema-registry


# docker run -d \
#   --name=schema-registry \
#   --link zoo-1:zookeeper \
#   --link kafka-1:kafka \
#   -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=localhost:2181 \
#   -e SCHEMA_REGISTRY_HOST_NAME=0.0.0.0 \
#   -e SCHEMA_REGISTRY_LISTENERS=http://0.0.0.0:8081 \
#   confluentinc/cp-schema-registry:4.0.0



# producer = KafkaProducer(bootstrap_servers='10.5.50.226:29092', value_serializer=lambda v: json.dumps(v).encode('utf-8'))

# try:
#     producer.send('iotavro', { "id":2,"deviceid":"120","latitude": 1999.23, "longitude": 23.3434, "temperature": "90", "created_date": "2017-01-26T00:00:00-05:00"})
# Exception as ex:
#     print(str(ex))


# docker run -d \
#   --name=schema-registry-1 `# Name of the Container Image` \
#   --link zoo-1:zookeeper \
#   --link kafka-$id:kafka \
#   -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL="172.31.0.114:2181" \
#   -e SCHEMA_REGISTRY_HOST_NAME=3.0.209.191 \
#   -p 8081:8081 \
#   confluent/schema-registry