# Generic Properties

## LOG4J_ROOT_LOGLEVEL: 
This is apache log level parameter, can be passed to any apache confluent we are        running in docker mode just be adding the prefix of the service we want to run. 
e.g: ZOOKEEPER_LOG4J_ROOT_LOGLEVEL, KAFKA_LOG4J_ROOT_LOGLEVEL etc



# Zookeeper
ZooKeeper is a centralized service for maintaining configuration information, naming,            providing distributed synchronization, and providing group services.

## Properties:


1. zk_id: Each node in a cluster has a unique zookeeper id.

2. ZOOKEEPER_CLIENT_PORT: 	Property from ZooKeeper's config zoo.cfg. The port at which the clients will        connect.

3. Zookeeper Server List:- While running zookeeper we have to pass the list servers in the format of zoo1:2888:3888 as a environment variable
e.g- "-e zk_server.1=Server1:2888:3888 -e zk_server.2=Server2:2888:3888 -e zk_server.3=Server3:2888:3888"

3. Port 2888 & 3888:- Port used by ZooKeeper peers to talk to each other. Zookeeper will use these         ports (2888, etc.) to connect the individual follower nodes to the leader nodes. The other ports        (3888, etc.) are used for leader election in the ensemble.

# Kafka Broker
A Kafka cluster consists of one or more servers (Kafka brokers), which are running Kafka.     Producers are processes that publish data (push messages) into Kafka topics within the broker. A         consumer of topics pulls messages off a Kafka topic.

## Properties:

1. KAFKA_BROKER_ID: Each broker inside the cluster have to a unique id.

2. KAFKA_ZOOKEEPER_CONNECT: Tells Kafka how to get in touch with ZooKeeper, a minimum of one Zookeeper Server IP need to passed, to connect to the cluster. It is always safe to pass more than one zookeeper address in case if one more zookeeper server have failed.
e.g 10.0.1.70:2181,10.0.1.94:2181,10.0.1.212:2181

3. KAFKA_ADVERTISED_LISTENERS: Listeners to publish to ZooKeeper for clients to use. In a Docker environment, your clients must be able to connect to Kafka and other services. The advertised listeners configuration setting describes how the host name that is advertised and can be reached by the client.It makes Kafka accessible from outside of the container by advertising its location on the Docker host.

4. Port 9092: The port at which Kafka Service run and listens for requests.


# Schema Registry
Schema Registry provides a serving layer for your metadata. It provides a RESTful interface for storing and retrieving Avro schemas. It provides serializers that plug into Kafka clients that handle schema storage and retrieval for Kafka messages that are sent in the Avro format.

## Parameters:

1. SCHEMA_REGISTRY_GROUP_ID: Group id used at the time of when Kafka is used for master election.

2. SCHEMA_REGISTRY_KAFKASTORE_CONNECTION_URL: ZooKeeper URL for the Kafka cluster
e.g 10.0.1.70:2181,10.0.1.94:2181,10.0.1.212:2181

3. SCHEMA_REGISTRY_HOST_NAME: The hostname advertised in ZooKeeper. This is required if if you are running Schema Registry with multiple nodes. Hostname is required because it defaults to the Java canonical hostname for the container, which may not always be resolvable in a Docker environment. Hostname must be resolveable because slave nodes serve registration requests indirectly by simply forwarding them to the current master, and returning the response supplied by the master.

4. SCHEMA_REGISTRY_LISTENERS: Comma-separated list of listeners that listen for API requests over either HTTP or HTTPS, over which Schema registry listens for requests.


# KAFKA-CONNECT:
Kafka Connect, an open source component of Apache Kafka, is a framework for connecting Kafka with external systems such as databases, key-value stores, search indexes, and file systems.
Using Kafka Connect you can use existing connector implementations for common data sources and sinks to move data into and out of Kafka.


## Properties:

1. CONNECT_BOOTSTRAP_SERVERS: A list of host/port pairs to use for establishing the initial connection to the Kafka cluster. The client will make use of all servers irrespective of which servers are specified here for bootstrapping. This list only impacts the initial hosts used to discover the full set of servers. This list should be in the form host1:port1,host2:port2. Since these servers are just used for the initial connection to discover the full cluster membership (which may change dynamically), this list need not contain the full set of servers (you may want more than one, though, in case a server is down).
e.g: 10.0.1.70:9092

2. CONNECT_REST_PORT:  Kafka Connect REST interface listens on for HTTP requests, through which one can add, delete modify the connectors.

3. CONNECT_GROUP_ID: A unique string that identifies the Connect cluster group this worker belongs to.

4. CONNECT_CONFIG_STORAGE_TOPIC: The name of the topic where connector and task configuration data are stored. This must be the same for all workers with the same group.id. Can be created manually otherwise kafka connect will create it automatically

5. CONNECT_OFFSET_STORAGE_TOPIC: The name of the topic where connector and task configuration data are stored. This must be the same for all workers with the same group.id.

6. CONNECT_STATUS_STORAGE_TOPIC: The name of the topic where connector and task configuration status updates are stored. This must be the same for all workers with the same group.id

7. CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR: The replication factor used when Kafka Connects creates the topic used to store connector and task configuration data. This should always be at least 3 for a production system, but cannot be larger than the number of Kafka brokers in the cluster.

8. CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR: The replication factor used when Kafka Connects creates the topic used to store connector offsets. This should always be at least 3 for a production system, but cannot be larger than the number of Kafka brokers in the cluster.

9. CONNECT_STATUS_STORAGE_REPLICATION_FACTOR: The replication factor used when Kafka Connects creates the topic used to store connector and task status updates. This should always be at least 3 for a production system, but cannot be larger than the number of Kafka brokers in the cluster.

10. CONNECT_KEY_CONVERTER, CONNECT_VALUE_CONVERTER: Converters are necessary to have a Kafka Connect  deployment support a particular data format when writing to or reading from Kafka. Tasks use converters to change the format of data from bytes to Connect internal data format and vice versa.By default, Confluent Platform provides the following converters:
    - AvroConverter (recommended): use with Confluent Schema Registry
    - JsonConverter: great for structured data
    - StringConverter: simple string format
    - ByteArrayConverter: provides a “pass-through” option that does no conversion

11. CONNECT_INTERNAL_KEY_CONVERTER & CONNECT_INTERNAL_VALUE_CONVERTER:

12. Converter class for internal key Connect data that implements the Converter interface. Used for converting data like offsets and configs.

13. CONNECT_PLUGIN_PATH: Java Plugin Path that are required to run our Kafka Setup.
