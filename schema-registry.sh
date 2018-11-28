i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


kafka_connection_url=""

j=0
for var in "$@"
do
    let j=j+1
    kafka_connection_url="$kafka_connection_url"$\Server$j":2181,"
done

echo $kafka_connection_url

eval SelfIP=$\Server$id


## Schema Registry on Node1/Host1
t="docker run -d \
  --name=schema-registry-$id `# Name of the Container Image` \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$kafka_connection_url \
  -e SCHEMA_REGISTRY_HOST_NAME=$SelfIP `# Hostname of schema Registry` \
  confluent/schema-registry"

eval $t