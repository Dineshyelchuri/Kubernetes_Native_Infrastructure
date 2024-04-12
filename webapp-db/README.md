# CSYE7125 - Advanced Cloud Computing
## webapp-db
This repository contains SQL scripts that gets placed in the flyway/sql path of the flyway image when the image is built using the Dockerfile in this repository.
##
Following command can be used to migrate the database data using SQL scripts to the target database.
##
``
docker run --name=flyway --rm quay.io/csye7125ruth/webapp-db -url=$DB_HOST -user=$DB_USERNAME -password=$DB_PASSWORD migrate
``