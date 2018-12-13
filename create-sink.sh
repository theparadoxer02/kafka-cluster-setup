# kafka connect Avro takes time to start
wait 40


eval SelfIP=$(hostname -I | cut -d" " -f 1)


# Create the Sink connector
curl -X POST -H "Content-Type: application/json" \
   --data '{
       "name": "iotavro-sink",
       "config": {
         "connector.class":"io.confluent.connect.jdbc.JdbcSinkConnector", 
         "tasks.max":"1",
         "topics":"iotavro",
         "connection.url": "jdbc:postgresql://10.5.50.234:5432/nextsoftiot?currentSchema=sensordata",
         "connection.user": "next_user",
         "connection.password":"next_pass"
         }
       }' \
   http://10.5.50.226:8083/connectors