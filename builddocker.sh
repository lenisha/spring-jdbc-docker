#!/bin/bash

mvn package -DskipTests
docker build -t spring-jdbc-docker .
docker tag spring-jdbc-docker lenisha/spring-jdbc-docker:8u252
docker push lenisha/spring-jdbc-docker:8u252