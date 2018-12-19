# confluent-kafka (0.11.6)
# kafka-python (1.4.3)



from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer
import time


value_schema_str = """
{
   "type": "record",
   "name": "User",
   "namespace": "country.avro",
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
      }
   ]
}"""

key_schema_str = """
{
   "type": "record",
   "name": "User",
   "namespace": "country.avro",
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
      }
   ]
}"""

value_schema = avro.loads(value_schema_str)
key_schema = avro.loads(key_schema_str)

value = {"temperature": 33.2, "deviceid":"9098", "latitude":  90.34 , "longitude": 334.4}
key = {"temperature": 33.2, "deviceid":"9098", "latitude":  90.34 , "longitude": 334.4}

avroProducer = AvroProducer({
    'bootstrap.servers': '3.0.166.133:9995',
    'schema.registry.url': 'http://3.0.166.133:8885',
    }, default_key_schema=key_schema, default_value_schema=value_schema)

avroProducer.produce(topic='nextiot', value=value, key=key)
avroProducer.flush()
