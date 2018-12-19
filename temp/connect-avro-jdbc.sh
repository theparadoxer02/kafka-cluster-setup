# Start ZooKeeper:
docker run -d \
    --name=zookeeper `# name of the container` \
    -e zk_server.1=192.168.10.110:2888:3888 \
    -e ZOOKEEPER_CLIENT_PORT=2181 `# port to which it is published` \
    -e ZOOKEEPER_TICK_TIME=2000 `# to determine which servers are up and running at any given time` \
    confluentinc/cp-zookeeper:3.3.0 `# Apache ZooKeeper Image name`


sleep 15

# Start Kafka
docker run -d \
    --link zookeeper:zookeeper \
    --name=kafka \
    -e KAFKA_ZOOKEEPER_CONNECT=192.168.10.110:2181 `# Zookeeper Service Port` \
    -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://192.168.10.110:9092 `# Publish Kakfa to Outside Port` \
    -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 `# Replication factor` \
    confluentinc/cp-kafka:3.3.0


sleep 10

# Start the Schema Registry:
docker run -d \
  --link zookeeper:zookeeper \
  --link kafka:kafka \
  --name=schema-registry `# Name of the Container Image` \
  -e SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL=192.168.10.110:2181 `# ZooKeeper URL for the Kafka cluster` \
  -e SCHEMA_REGISTRY_HOST_NAME=192.168.10.110 `# Hostname of schema Registry` \
  -e SCHEMA_REGISTRY_LISTENERS=http://192.168.10.110:8081 `# URL of schema Registry` \
  confluentinc/cp-schema-registry:3.3.0


# We will create these topics now using the Kafka broker we created above

## Create Topic quickStart-Avro-Offset
docker run \
  --link zookeeper:zookeeper \
  --link kafka:kafka \
  --rm \
  confluentinc/cp-kafka:3.3.0 \
  kafka-topics --create --topic quickstart-avro-offsets --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 192.168.10.110:2181


## Create Topic named: quickStart-Avro-Config
docker run \
  --link zookeeper:zookeeper \
  --link kafka:kafka \
  --rm \
  confluentinc/cp-kafka:3.3.0 \
  kafka-topics --create --topic quickstart-avro-config --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 192.168.10.110:2181

## Create Topic named: quickStart-Avro-status
docker run \
  --link zookeeper:zookeeper \
  --link kafka:kafka \
  --rm \
  confluentinc/cp-kafka:3.3.0 \
  kafka-topics --create --topic quickstart-avro-status --partitions 1 --replication-factor 1 --if-not-exists --zookeeper 192.168.10.110:2181

## Check if all the topics are created
docker run \
   --link zookeeper:zookeeper \
  --link kafka:kafka \
   --rm \
   confluentinc/cp-kafka:3.3.0 \
   kafka-topics --describe --zookeeper 192.168.10.110:2181


# Download the POSTGRES JDBC driver and copy it to the jars folder. If you are running Docker Machine, 
# you will need to SSH into the VM to run these commands. You may have to run the command as root.
mkdir -p /usr/share/java
cd /usr/share/java
sudo wget https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
exit


# Start Kafka Connect Container
docker run -d \
  --name=kafka-connect-avro \
  --link zookeeper:zookeeper \
  --link kafka:kafka \
  -e CONNECT_BOOTSTRAP_SERVERS=192.168.10.110:9092 `#  Addresses of the Kafka brokers` \
  -e CONNECT_REST_PORT=28083 `# Kafka connect REST API PORT` \
  -e CONNECT_GROUP_ID="quickstart-avro" `# Create a Group Id` \
  -e CONNECT_CONFIG_STORAGE_TOPIC="quickstart-avro-config" `# First Topic created using Kafka-Topic` \
  -e CONNECT_OFFSET_STORAGE_TOPIC="quickstart-avro-offsets" `# Second Topic created using Kafka-Topic` \
  -e CONNECT_STATUS_STORAGE_TOPIC="quickstart-avro-status" `# Third Topic created using Kafka-Topic` \
  -e CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR=1 `# Factor used when Kafka Connects creates the topic used to store connector and task` \
  -e CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR=1 `# Factor used when Kafka Connects creates the topic used to store connector offsets` \
  -e CONNECT_STATUS_STORAGE_REPLICATION_FACTOR=1 `# Factor used when connector and task configuration status updates are stored` \
  -e CONNECT_KEY_CONVERTER="io.confluent.connect.avro.AvroConverter" ` # Data Format Converter for Key` \
  -e CONNECT_VALUE_CONVERTER="io.confluent.connect.avro.AvroConverter" `#  Data Format Converter for Value` \
  -e CONNECT_KEY_CONVERTER_SCHEMA_REGISTRY_URL="http://192.168.10.110:8081" `# Connect Key Schema Registry URL` \
  -e CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL="http://192.168.10.110:8081" `# Connect Value Schema Registry URL` \
  -e CONNECT_INTERNAL_KEY_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Key` \
  -e CONNECT_INTERNAL_VALUE_CONVERTER="org.apache.kafka.connect.json.JsonConverter" `# Internal Data Format Converter for Value` \
  -e CONNECT_REST_ADVERTISED_HOST_NAME="192.168.10.110" `# Connect Rest Publish Host` \
  -e CONNECT_LOG4J_ROOT_LOGLEVEL=DEBUG `# Connect Log Level` \
  -e CONNECT_PLUGIN_PATH=/usr/share/java/ \
  confluentinc/cp-kafka-connect:latest


docker run -d \
    --net=host \
    --name=kafka-rest \
    -e KAFKA_REST_ZOOKEEPER_CONNECT=192.168.10.110:2181 \
    -e KAFKA_REST_LISTENERS=http://0.0.0.0:8082 \
    -e KAFKA_REST_SCHEMA_REGISTRY_URL=http://192.168.10.110:8081 \
    -e KAFKA_REST_HOST_NAME=kafka-rest \
    confluentinc/cp-kafka-rest:3.3.0



# Run the POSTGRES SERVER
docker run -d \
  --name=quickstart-postgres `# name of the container` \
  --net=host `# network name` \
  -e POSTGRES_PASSWORD=confluent `# postgres root password` \
  -e POSTGRES_USER=confluent `# my postgres user` \
  -e POSTGRES_PASSWORD=confluent `# Postgres User Password` \
  -e POSTGRES_DB=connect_test `# Database Name` \
  postgres:9.3.6


docker exec -it quickstart-postgres bash

psql -h 192.168.10.110 -p 5432 -U postgres

CREATE TABLE IF NOT EXISTS test (
  id serial NOT NULL PRIMARY KEY,
  name varchar(100),
  email varchar(200),
  department varchar(200),
  modified timestamp(0) default CURRENT_TIMESTAMP NOT NULL
);
GRANT ALL PRIVILEGES ON DATABASE test to confluent;

CREATE INDEX modified_index ON test (modified);

INSERT INTO test (name, email, department) VALUES ('alice', 'alice@abc.com', 'engineering');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');
INSERT INTO test (name, email, department) VALUES ('bob', 'bob@abc.com', 'sales');

\q

exit


# Create the JDBC Source connector.

export CONNECT_HOST=192.168.10.110

curl -X POST \
  -H "Content-Type: application/json" \
  --data '{
    "name": "source",
    "config": {
      "connector.class": "io.confluent.connect.jdbc.JdbcSourceConnector",
      "tasks.max": 1,
      "connection.url": "jdbc:postgresql://nextiot.cer5vnogozpc.ap-southeast-1.rds.amazonaws.com:5432/nextiot",
      "connection.user": "next_user",
      "connection.password": "next_pass",
      "mode": "incrementing",
      "incrementing.column.name": "id",
      "timestamp.column.name": "modified",
      "topic.prefix": "nextiot-jdbc-", 
      "poll.interval.ms": 1000
    }
  }' \
  http://192.168.10.110:28083/connectors

curl -s -X GET http://$CONNECT_HOST:28083/connectors/new-connector/status


# The JDBC sink create intermediate topics for storing data
docker run \
   --net=host \
   --rm \
   confluentinc/cp-kafka:4.1.0 \
   kafka-topics --describe --zookeeper 192.168.10.110:2181


# Now you will read from the quickstart-jdbc-test topic to check if the    works.
docker run \
 --net=host \
 --rm \
 confluentinc/cp-schema-registry:4.1.0 \
 kafka-avro-console-consumer --bootstrap-server 192.168.10.110:9092 --topic quickstart-jdbc-test --new-consumer --from-beginning --max-messages 10




from kafka