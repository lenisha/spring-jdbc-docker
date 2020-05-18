#!/bin/bash

mvn package -DskipTests
docker build -t spring-jdbc-docker .
docker tag spring-jdbc-docker lenisha/spring-jdbc-docker
docker push lenisha/spring-jdbc-docker