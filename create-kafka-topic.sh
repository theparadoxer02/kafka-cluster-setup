# Set Server Variable with argument passed like Server1=10.5.4..90, Server2=10.45.3.34
wait 10

i=0
for var in "$@"
do
    echo "$var"
    let i=i+1
    eval Server$i=$var
done


kafka_connection_url=""     # Server links like Server1:2181,Server2:2181,

j=0
for var in "$@"
do
    let j=j+1
    kafka_connection_url="$kafka_connection_url"$\Server$j":2181,"
done

# create 3 kafka topics after entering into the bash shell of kafka-server running on 1st node
# `$#` is the total number of nodes passed in the argument

t = 'docker exec -it kafka-$id sh -c " \
  kafka-topics --create --topic quickstart-avro-offsetss --partitions $# --replication-factor $# --if-not-exists --zookeeper $kafka_connection_url \
  && kafka-topics --create --topic quickstart-avro-config --partitions $# --replication-factor $# --if-not-exists --zookeeper $kafka_connection_url \
  && kafka-topics --create --topic quickstart-avro-status --partitions $# --replication-factor $# --if-not-exists --zookeeper $kafka_connection_url" \
  '

eval $t