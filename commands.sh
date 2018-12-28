
kafka-avro-console-producer   --broker-list 10.0.1.94:9092 10.0.1.212:9092 10.0.1.212:9092 --topic nextiot   --property schema.registry.url=http://10.0.1.94:8081   --property value.schema='{"type": "record","name": "Sensordata","fields": [{"name": "deviceid", "type": "string"},{"name": "latitude",  "type": "float"},{"name": "longitude", "type": "float"}]}'

kafka-avro-console-consumer   --zookeeper 10.0.1.70:2181 10.0.1.212:2181 10.0.1.212:2181 --topic nextiot   --property schema.registry.url=http://10.0.1.70:8081


# Producer using Public IP Address

kafka-avro-console-producer   --broker-list 3.0.166.133:9995 3.0.166.133:9996 3.0.166.133:9997 --topic nextiot   --property schema.registry.url=http://3.0.166.133:8885   --property value.schema='{"type": "record","name": "Sensordata","fields": [{"name": "deviceid", "type": "string"},{"name": "latitude",  "type": "float"},{"name": "longitude", "type": "float"}]}'```



from kafka import KafkaProducer
a = KafkaProducer(bootstrap_servers=['3.0.166.133:9995'])

# SSH to Bastion Server
ssh-add -k NextSoftware.pem
ssh -A -i NextSoftware.pem ubuntu@3.0.206.10

ssh centos@10.0.1.70
ssh centos@10.0.1.212
ssh centos@10.0.1.94

psql -h 10.0.1.233 -U next_user -d nextiot

\c nextiot

select * from nextiot;


git clone https://gitlab.com/theparadoxer02/iotflaskapi
cd iotflaskapi
pip install -r requirements.txt
export FLASK_APP=run.py


pip install uwsgi flask


# Flask Api deployement
sudo yum install epel-release
sudo yum install python-pip
pip install virtualenv

# Installing Uwsgi
yum install build-essential python python-dev
yum groupinstall "Development Tools"
yum install python-devel
pip install uwsgi


# Gunicorn
gunicorn --bind 0.0.0.0:5555 wsgi:app
gunicorn --bind 0.0.0.0:5555 wsgi:app
gunicorn --bind 0.0.0.0:5555 wsgi:app


nohup /home/centos/flaskapi/iotflaskapi/gunicorn.sh &

# Front end and backend SERVER
ssh ubuntu@52.221.83.184


INSERT INTO nextiot (deviceid, latitude, longitude, temperature) VALUES ('2', 28.671310915880834, 77.17620849609375, 23);


# PSQL query to get distinct device id and corresponding data
select distinct on (deviceid) deviceid, temperature, latitude, longitude from nextiot order by deviceid, temperature;


# Ping all ansible hosts
ansible all -m ping -i hosts.ini
ansible-playbook -i hosts.ini --become playbook.yml


curl --header "Content-Type: application/json" \
    --request POST \
    --data '{"deviceid":"7", "temperature": 25, "latitude": 34.5, "longitude": 29.43, "timestamp": 1545655607573}' \
     http://10.0.1.70:5555/topic

    
# Check Kafka Version
docker logs kafka | egrep -i "kafka\W+version"