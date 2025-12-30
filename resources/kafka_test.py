from kafka import KafkaProducer
from kafka import KafkaConsumer

producer = KafkaProducer()
consumer = KafkaConsumer(bootstrap_servers=['localhost:9092'])

producer.send(
	'flight_delay_classification_request',
  '{"Hello": "World!"}'.encode()
)

