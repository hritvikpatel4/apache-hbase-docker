#!/usr/bin/env bash

echo "creating apache hbase image"
sudo docker build -t ntwine/apache-hbase:latest .
echo "pushing apache hbase image to docker registry"
sudo docker push ntwine/apache-hbase:latest

echo "Done!"