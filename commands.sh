
kafka-avro-console-producer   --broker-list 10.0.1.94:9092 10.0.1.212:9092 10.0.1.212:9092 --topic nextiot   --property schema.registry.url=http://10.0.1.94:8081   --property value.schema='{"type": "record","name": "Sensordata","fields": [{"name": "deviceid", "type": "string"},{"name": "latitude",  "type": "float"},{"name": "longitude", "type": "float"}]}'

kafka-avro-console-consumer   --zookeeper 10.0.1.70:2181 10.0.1.212:2181 10.0.1.212:2181 --topic nextiot   --property schema.registry.url=http://10.0.1.70:8081

ssh-add -K NextSoftware.pem
ssh -A -i NextSoftware.pem ubuntu@13.229.138.138

ssh centos@10.0.1.70
psql -h 10.0.1.233 -U next_user -d nextiot