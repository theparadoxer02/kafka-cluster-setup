# kafka connect Avro takes time to start
wait 20


curl -X POST -H "Content-Type: application/json" \
  --data '{
    "name": "nextiot-sink",
    "config": {
        "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
        "connection.url": "jdbc:postgresql://172.17.0.11:5432/nextiot",
        "connection.user": "next_user",
        "connection.password": "next_pass",
        "auto.create": true,
        "auto.evolve": true,
        "topics": "nextiot"
        }
    }' http://10.5.50.233:8083/connectors