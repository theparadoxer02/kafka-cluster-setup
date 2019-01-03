from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer
import time

value_schema_str = """
{
   "type": "record",
   "name": "User",
   "namespace": "iot.avro",
   "fields": [
      {
         "name": "deviceid",
         "type": "string"
      },
      {
         "name": "temperature",
         "type": [
            "float",
            "null"
         ]
      },
      {
         "name": "latitude",
         "type": [
            "float",
            "null"
         ]
      },
      {
         "name": "longitude",
         "type": [
            "float",
            "null"
         ]
      },
      {
         "name": "timestamp",
         "type": [{
             "type" : "long",
             "logicalType" : "timestamp-millis"
         }, "null"]
      }
   ]
}"""

key_schema_str = """
{
   "type": "record",
   "name": "User",
   "namespace": "iot.avro",
   "fields": [
      {
         "name": "deviceid",
         "type": "string"
      },
      {
         "name": "temperature",
         "type": "float"
      },
      {
         "name": "latitude",
         "type": "float"
      },
      {
         "name": "longitude",
         "type": "float"
      },
      {
         "name": "timestamp",
         "type": "long"
      }
   ]
}"""

def push_to_kafka(key, value):
    value_schema = avro.loads(value_schema_str)
    key_schema = avro.loads(key_schema_str)

    avroProducer = AvroProducer({
        'bootstrap.servers': 'localhost:9092',
        'schema.registry.url': 'http://localhost:8081',
        }, default_key_schema=key_schema, default_value_schema=value_schema)

    avroProducer.produce(topic='nextiot', value=value, key=key)
    avroProducer.flush()