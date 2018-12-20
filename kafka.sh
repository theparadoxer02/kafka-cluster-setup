# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
source ~/.bashrc

i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


kafka_server_link=""    # Server links like Server1:2181,Server2:2181,
kafka_server_list=""    # For Argument like "-e Server1:$Server1 -e Server2:$Server2"
kafka_adv_listener=""
j=0
for var in "$@"
do
    let j=j+1
    kafka_server_link="$kafka_server_link"$\Server$j":2181,"
    kafka_adv_listener="$kafka_adv_listener"PLAINTEXT://$\Server$j":9092,"
    kafka_server_list="$kafka_server_list -e Server$j="$\Server$j""
done

# echo $kafka_server_list
# echo $kafka_server_list

eval SelfIP=$\Server$id     # Ip address of the current node

## Kafka on Node1 / Host1:
t="docker run -d \
    --name kafka-$id \
    --link zoo-$id:zookeeper \
    -e KAFKA_BROKER_ID=$id `# Kafka Broker Id number` \
    -e KAFKA_ZOOKEEPER_CONNECT=$kafka_server_link `# Zookeeper all Servers Address` \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://$SelfIP:9092 \
    -p 9092:9092 \
    confluent/kafka"

echo $t

eval $t
