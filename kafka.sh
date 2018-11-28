i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


kafka_server_link=""
kafka_server_list=""

j=0
for var in "$@"
do
    let j=j+1
    kafka_server_link="$kafka_server_link"$\Server$j":2181,"
    kafka_server_list="$kafka_server_list -e Server$j="$\Server$j""
done

echo $kafka_server_list
echo $kafka_server_list

eval SelfIP=$\Server$id

## Kafka on Node1 / Host1:
t="docker run -d \
    --name kafka-$id \
    --link zoo-$id:zookeeper \
    -e KAFKA_BROKER_ID=$id `# Kafka Broker Id number` \
    -e KAFKA_ZOOKEEPER_CONNECT=$kafka_server_link `# Zookeeper all Servers Address` \
    $kafka_server_list \
    -e KAFKA_ADVERTISED_HOST_NAME=$SelfIP  `# Self server Public IP` \
    -e KAFKA_ADVERTISED_PORT=9092 `# Kafka Service port` \
    -p 9092:9092 \
    confluent/kafka"
echo $t
eval $t