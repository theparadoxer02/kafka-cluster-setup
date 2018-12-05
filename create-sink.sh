# kafka connect Avro takes time to start
wait 40


eval SelfIP=$(hostname -I | cut -d" " -f 1)


# Create the Sink connector
curl -X POST -H "Content-Type: application/json" \
   --data '{
       "name": "iot-avro-file-sink",
       "config": {
         "connector.class":"io.confluent.connect.jdbc.JdbcSinkConnector", 
         "tasks.max":"1", "topics":"iot-jdbc-test",
         "connection.url": "",
         "connection.user": "",
         "connection.password":""
         }
       }' \
   http://$SelfIP:8083/connectors