import io
import random
import avro.schema
from avro.io import DatumWriter
from kafka import SimpleProducer
from kafka import KafkaClient

# To send messages synchronously
KAFKA = KafkaClient('3.0.166.133:9995')
PRODUCER = SimpleProducer(KAFKA)

# Kafka topic
TOPIC = "nextiot"

# Path to user.avsc avro schema
SCHEMA_PATH = "schema.avsc"
SCHEMA = avro.schema.parse(open(SCHEMA_PATH).read())

for i in xrange(10):
    writer = DatumWriter(SCHEMA)
    bytes_writer = io.BytesIO()
    encoder = avro.io.BinaryEncoder(bytes_writer)
    writer.write({"deviceid":"010001","latitude": { "float": 32.34},"longitude": {"float" :23.33}}, encoder)
    raw_bytes = bytes_writer.getvalue()
    PRODUCER.send_messages(TOPIC, raw_bytes)


import avro.schema
from avro.datafile import DataFileReader, DataFileWriter
from avro.io import DatumReader, DatumWriter
 
schema = avro.schema.parse(open("schema.avsc").read())  # need to know the schema to write
 
writer = DataFileWriter(open("users.avro", "wb"), DatumWriter(), schema)
writer.append({"deviceid":"010098"})
writer.append({"latitude": { "float": 2234.34 }, "longitude": { "float": 334.4}})
writer.close()

# {"deviceid":"010098", "latitude": { "float": 2234.34 }, "longitude": { "float": 334.4}}