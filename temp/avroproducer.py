from confluent_kafka import avro
from confluent_kafka.avro import AvroProducer


value_schema_str = """
{
    "namespace" : "country.avro",
	"type": "record",
	"name": "value",
	"fields": [
		{"name": "deviceid",  "type": "string"},
		{"name": "latitude",  "type": "float"},
		{"name": "longitude", "type": "float"}
	]
}
"""

key_schema_str = """
{
   	"namespace" : "country.avro",
	"type": "record",
	"name": "key",
	"fields": [
		{"name": "id", "type": "int"}
	]
}
"""

value_schema = avro.loads(value_schema_str)
key_schema = avro.loads(key_schema_str)

value = {"deviceid": "3434", "latitude": 22.34, "longitude": 334.4}
key = {"id": 1}

avroProducer = AvroProducer({
    'bootstrap.servers': '3.0.166.133:9995',
    'schema.registry.url': 'http://3.0.166.133:8885',
    }, default_key_schema=key_schema, default_value_schema=value_schema)

avroProducer.produce(topic='nextiot', value=value, key=key)
avroProducer.flush()


# curl -X PUT -H "Content-Type: application/vnd.schemaregistry.v1+json" \
# --data '{"compatibility": "FORWARD"}' \
# http://localhost:8081/config