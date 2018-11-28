# kafka connect Avro takes time to start
wait 40


eval SelfIP=$(hostname -I | cut -d" " -f 1)


# Create the Sink connector
curl -X POST -H "Content-Type: application/json" \
   --data '{
       "name": "quickstart-avro-file-sink2",
       "config": {
         "connector.class":"io.confluent.connect.jdbc.JdbcSinkConnector", 
         "tasks.max":"1", "topics":"quickstart-jdbc-test",
         "connection.url": "",
         "connection.user": "",
         "connection.password":""
         }
       }' \
   http://$SelfIP:8083/connectors