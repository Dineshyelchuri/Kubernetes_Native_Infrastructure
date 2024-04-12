# CSYE7125 - Advanced Cloud Computing
# kafka-consumer
This Kafka consumer application is responsible for reading the healthcheck data from the kafka healthcheck topic and wrtiting the data to the postgresql database.
## Third party libraries:
Packages required to run:
- Kafkajs
- Sequelize
- pg
```
npm install kafkajs pg sequelize
```
## Prerequisites for running the application locally:
```javascript
// install dependencies
npm install
// Run the Application
node app.js
```
## Command to containerize the application:
```
docker build -t [registry]/[repo_name]:[tag] .
```