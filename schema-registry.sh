# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
source ~/.bashrc
docker rm -f schema-registry-$id


sleep 4

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
    kafka_bootstrap_servers="$kafka_bootstrap_servers"$\Server$j":2181,"
done

# echo $kafka_bootstrap_servers

eval SelfIP=$\Server$id


## Schema Registry on Node1/Host1
t="docker run -d \
    --restart=on-failure:10 \
    --name=schema-registry-$id `# Name of the Container Image` \
    --link zoo-$id:zookeeper \
    --link kafka-$id:kafka \
    -e SCHEMA_REGISTRY_GROUP_ID='nextiot' \
    -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=$kafka_bootstrap_servers \
    -e SCHEMA_REGISTRY_HOST_NAME=$SelfIP `# Hostname of schema Registry` \
    -e SCHEMA_REGISTRY_LISTENERS=http://0.0.0.0:8081 \
    -e SCHEMA_REGISTRY_LOG4J_ROOT_LOGLEVEL=DEBUG \
    -p 8081:8081 \
    confluentinc/cp-schema-registry:5.1.0"

eval $t
