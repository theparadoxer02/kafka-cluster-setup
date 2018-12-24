# kafka connect Avro takes time to start
sleep 20


curl -X POST -H "Content-Type: application/json" \
  --data '{
    "name": "nextiot-sink",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "connection.url": "jdbc:postgresql://10.10.0.233:5432/nextiot",
        "connection.user": "next_user",
        "connection.password": "next_pass",
        "auto.create": true,
        "auto.evolve": true,
        "topics": "nextiot"
        }
    }' http://localhost:8083/connectors