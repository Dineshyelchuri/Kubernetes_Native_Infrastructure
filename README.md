# CSYE7125 - Advanced Cloud Computing
# kafka-helm-chart
This helm chart installs all the necessary kubernetes objects required to run the kafka cluster.
##
Chart dependencies:
- PostgreSql
- Kafka
##
To install the helm chart, run the following command:
```
helm install [release_name] [./chart_folder]
```
##
To Uninstall the chart, try
```
helm uninstall [release_name]
```
##
This Kafka helm chart also installs necessary kubernetes objects required to run the kafka consumer which reads the data from the healthcheck topic and writes to the Postgresql database.

NOTE: It may take a while for the Kafka cluster to get set up completely which includes three controllers/brokers.