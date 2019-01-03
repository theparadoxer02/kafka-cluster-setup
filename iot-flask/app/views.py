from flask import render_template
from app import app
from flask import request
from app.kafka_producer import push_to_kafka


@app.route('/')
def hello():
    return "<h1 style='color:blue'>Hello There!</h1>"

@app.route('/topic', methods=['POST'])
def index():
    data = request.json
    deviceid = str(data['deviceid'])
    latitude = data['latitude']
    longitude = data['longitude']
    temperature = data['temperature']
    timestamp = data['timestamp']

    value = {"temperature": temperature, "deviceid": deviceid, "latitude":  latitude , "longitude": longitude, "timestamp": timestamp}
    key = {"temperature": temperature, "deviceid": deviceid, "latitude":  latitude , "longitude": longitude, "timestamp": timestamp}

    print(key)
    try:
        push_to_kafka(key=key, value=value)
        return 'Data Posted', 200
    except:
        return "Could not push  data to Kafka", 500


