
kafka-avro-console-producer   --broker-list 10.0.1.94:9092 10.0.1.212:9092 10.0.1.212:9092 --topic nextiot   --property schema.registry.url=http://10.0.1.94:8081   --property value.schema='{"type": "record","name": "Sensordata","fields": [{"name": "deviceid", "type": "string"},{"name": "latitude",  "type": "float"},{"name": "longitude", "type": "float"}]}'

kafka-avro-console-consumer   --zookeeper 10.0.1.70:2181 10.0.1.212:2181 10.0.1.212:2181 --topic nextiot   --property schema.registry.url=http://10.0.1.70:8081


# Producer using Public IP Address

kafka-avro-console-producer   --broker-list 3.0.166.133:9995 3.0.166.133:9996 3.0.166.133:9997 --topic nextiot   --property schema.registry.url=http://3.0.166.133:8885   --property value.schema='{"type": "record","name": "Sensordata","fields": [{"name": "deviceid", "type": "string"},{"name": "latitude",  "type": "float"},{"name": "longitude", "type": "float"}]}'```



from kafka import KafkaProducer
a = KafkaProducer(bootstrap_servers=['3.0.166.133:9995'])


ssh-add -K NextSoftware.pem
ssh -A -i NextSoftware.pem ubuntu@13.229.138.138

ssh centos@10.0.1.70
ssh centos@10.0.1.212
ssh centos@10.0.1.94

psql -h 10.0.1.233 -U next_user -d nextiot


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
gunicorn --bind 0.0.0.0:5556 wsgi:app
gunicorn --bind 0.0.0.0:5555 wsgi:app
gunicorn --bind 0.0.0.0:5555 wsgi:app


nohup /home/centos/flaskapi/iotflaskapi/gunicorn.sh &