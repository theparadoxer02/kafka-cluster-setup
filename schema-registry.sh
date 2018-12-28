source ~/.bashrc
docker rm -f schema-registry-$id

i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


kafka_bootstrap_servers=""  # Server links like Server1:2181,Server2:2181,

j=0
for var in "$@"
do
    let j=j+1
    kafka_bootstrap_servers="$kafka_bootstrap_servers"PLAINTEXT://$\Server$j":9092,"
done

# echo $kafka_connection_url

eval SelfIP=$\Server$id


## Schema Registry on Node1/Host1
t="docker run -d \
  --name=schema-registry-$id `# Name of the Container Image` \
  --link zoo-$id:zookeeper \
  --link kafka-$id:kafka \
  -e SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS=$kafka_bootstrap_servers \
  -e SCHEMA_REGISTRY_HOST_NAME=$SelfIP `# Hostname of schema Registry` \
  -e SCHEMA_REGISTRY_LOG4J_ROOT_LOGLEVEL=DEBUG \
  -p 8081:8081 \
  confluent/schema-registry"

eval $t
