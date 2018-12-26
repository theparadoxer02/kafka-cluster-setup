# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
wait 10

i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


zookeeper_connection_url=""     # Server links like Server1:2181,Server2:2181,

j=0
for var in "$@"
do
    let j=j+1
    zookeeper_connection_url="$zookeeper_connection_url"$\Server$j":2181,"
done

# create 3 kafka topics after entering into the bash shell of kafka-server running on 1st node
# `$#` is the total number of nodes passed in the argument


# When Creating Topics are Kafka Connect manually
#  kafka-topics --create --topic iot-avro-config --partitions 1 --replication-factor 3 --if-not-exists --zookeeper $zookeeper_connection_url \
#   && kafka-topics --create --topic iot-avro-offsets --partitions 50 --replication-factor 3 --if-not-exists --zookeeper $zookeeper_connection_url \
#   && kafka-topics --create --topic iot-avro-status --partitions 3 --replication-factor 10 --if-not-exists --zookeeper $zookeeper_connection_url" \


t = 'docker exec -it kafka-$id sh -c " \
   && kafka-topics --create --topic nextiot --partitions $# --replication-factor $# --if-not-exists --zookeeper $zookeeper_connection_url" \
  '

eval $t



# kafka-topics --create --topic nextiot --partitions 1 --replication-factor 1 --if-not-exists     --zookeeper zookeeper:2181
# # kafka-topics --create --topic iotavro --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 10.5.50.226:2181

# kafka-console-producer --request-required-acks 1 \
# --broker-list kafka:9092 --topic nextiot && echo 'Produced 42 messages.'"


# kafka-topics --create --topic iot-avro-config --partitions 3 --replication-factor 2 --if-not-exists  --zookeeper 10.0.1.70:2181

# kafka-topics --create --topic iot-avro-offsets --partitions 1 --replication-factor 1 --if-not-exists  --zookeeper zookeeper:2181

# kafka-topics --create --topic iot-avro-status --partitions 1 --replication-factor 1 --if-not-exists  --zookeeper zookeeper:2181


# kafka-topics --create --topic nextiot --partitions 1 --replication-factor 1 --if-not-exists  --zookeeper 10.5.50.233:2181
