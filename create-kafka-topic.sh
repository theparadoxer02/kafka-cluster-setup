
wait 10

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


docker exec -it kafka-$id sh -c " \
  kafka-topics --create --topic quickstart-avro-offsetss --partitions $# --replication-factor $# --if-not-exists --zookeeper $kafka_connection_url \
  && kafka-topics --create --topic quickstart-avro-config --partitions $# --replication-factor $# --if-not-exists --zookeeper $kafka_connection_url \
  && kafka-topics --create --topic quickstart-avro-status --partitions $# --replication-factor $# --if-not-exists --zookeeper $kafka_connection_url"
