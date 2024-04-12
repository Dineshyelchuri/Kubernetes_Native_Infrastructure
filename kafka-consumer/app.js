const db = require(__dirname + "/services/db");
const KafkaMessage = require(__dirname + "/models/Kafka");
const { Kafka } = require('kafkajs');

db.sync().then(() => {
    console.log('Tables are created successfully!');
  }).catch((error) => {
    console.log('Unable to create tables : ', error);
});

const kafka = new Kafka({
  clientId: 'kafka-consumer',
  brokers: [process.env.KAFKA_SERVER],
  // ssl: true,
  sasl: {
    mechanism: 'plain',
    username: process.env.KAFKA_USER,
    password: process.env.KAFKA_PASSWORD,
  },
});

function processMessage(message) {
  console.log({
    key: message.key.toString(),
    value: message.value.toString(),
  });

  return KafkaMessage.create({
    timestamp: JSON.parse(message.value.toString()).timestamp,
    uri: JSON.parse(message.value.toString()).url,
    status: JSON.parse(message.value.toString()).status,
    expected_status_code: JSON.parse(message.value.toString()).expected_status_code,
    headers: JSON.parse(message.value.toString()).headers,
  });
}

function commitOffsets(consumer, topic, partition, offset) {
  return consumer.commitOffsets([{ topic, partition, offset: offset + 1 }]);
}

async function runConsumer() {
  const consumer = kafka.consumer({ groupId: 'consumer-group' });
  await consumer.connect();
  await consumer.subscribe({ topic: 'healthcheck' });

  consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      processMessage(message)
        .then(() => {
          console.log('Kafka message data stored in the database.');
          return commitOffsets(consumer, topic, partition, message.offset);
        })
        .catch((error) => {
          console.error('Error storing Kafka message data:', error);
        });
    },
  });
}

runConsumer().catch((error) => {
  console.error('Error running consumer:', error);
});
