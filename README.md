# Spring/Hibernate App on Azure AKS (Tomcat) using JNDI to access SQL Server on Azure  

Code for the article posted on dzone: https://dzone.com/articles/migrating-java-applications-to-azure-app-service-p

## Spring Hibernate JNDI Example

This Spring example is based on tutorial [Hibernate, JPA & Spring MVC - Part 2] (https://www.alexecollins.com/tutorial-hibernate-jpa-spring-mvc-part-2/) by Alex Collins

Spring application uses hibernate to connect to SQL Server. Hibernate is using container managed JNDI Data Source.

There are few options to configure JNDI for the web application running undet Tomcat (Tomcat JNDI)[https://www.journaldev.com/2513/tomcat-datasource-jndi-example-java] :

- Application context.xml - located in app `META-INF/context.xml` - define Resource element in the context file and container will take care of loading and configuring it.
- Server server.xml - Global, shared by applications, defined in `tomcat/conf/server.xml`
- server.xml and context.xml - defining Datasource globally and including ResourceLink in application context.xml

# Docker
```
mvn package -DskipTests
docker build -t spring-jdbc-docker .
docker tag spring-jdbc-docker lenisha/spring-jdbc-docker
docker push lenisha/spring-jdbc-docker

docker run --rm -it -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS"  spring-jdbc-docker
```

```
export SQL_URL="jdbc:sqlserver://testmetoday.database.windows.net:1433;database=testae;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
export SQL_PASSWORD=xxx
export SQL_USER=todayadmin@testmetoday
export JAVA_OPTS="-DSQL_URL='$SQL_URL' -DSQL_USER=$SQL_USER -DSQL_PASSWORD=$SQL_PASSWORD"

```

# K8S

- Create Secrets for SQL and AppDynamics and ConfigMap for `logging.properties` for JDBC logs
```
kubectl create secret generic sqlpass --from-literal=SQL_PASS=xxxx

kubectl create secret generic appdynamicspass --from-literal=APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY=XXXX

kubectl apply -f ./
```


```
curl http://51.143.109.195/spring-jdbc-docker/users.html
```

# LOAD TEST
Load testing done using utility `hey` and docker image with script running as ACI group in a different region.

```
az container create -g jogardn-aks -n loadtestspringget --location westus --image lenisha/loadtest-spring:latest --restart-policy Always -e SERVICE_ENDPOINT=http://51.143.109.195/spring-jdbc-docker/users.html

az container logs -g jogardn-aks -n loadtestspringget
az container start -g jogardn-aks -n loadtestspringget

az container delete -g jogardn-aks -n loadtestspringget

az container create -g jogardn-aks -n loadtestspringpost --location westus --image lenisha/loadtest-spring:latest --restart-policy Never -e SERVICE_ENDPOINT=http://51.143.109.195/spring-jdbc-docker/create-user.html --command-line '/app/loadtest-post.sh'


az container logs -g jogardn-aks -n loadtestspringpost
az container delete -g jogardn-aks -n loadtestspringpost
```

### Artillery Load test

```
npm install -g artillery
artillery quick --count 10 -n 20 http://51.143.109.195/spring-jdbc-docker/users100.html
```


### Results

With only one pod in replicaset Tomcat starts to queue up pretty quickly
```
Phase 3: Load test - 30 seconds, 1600 users.
Details (average, fastest, slowest):
  DNS+dialup:   0.7815 secs, 0.9255 secs, 20.0002 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:    0.0002 secs, 0.0000 secs, 0.0092 secs
  resp wait:    0.4542 secs, 0.0540 secs, 3.9736 secs
  resp read:    0.0262 secs, 0.0000 secs, 0.3960 secs

Status code distribution:
  [200] 3050 responses

Error distribution:
  [988] Get "http://51.143.109.195/spring-jdbc-docker/users.html": context deadline exceeded (Client.Timeout exceeded while awaiting headers)      
  [401] Get "http://51.143.109.195/spring-jdbc-docker/users.html": dial tcp 51.143.109.195:80: i/o timeout (Client.Timeout exceeded while awaiting 
headers)

Waiting 15 seconds for the cluster to stabilize
\nPhase 4: Load test - 30 seconds, 3200 users.

Summary:
  Total:        49.6588 secs
  Slowest:      20.0003 secs
  Fastest:      0.8639 secs
  Average:      10.3038 secs
  Requests/sec: 156.9511


Response time histogram:
  0.864 [1]     |
  2.778 [205]   |■■■■■■■■■■■■■■■■■■■
  4.691 [367]   |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  6.605 [348]   |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  8.518 [346]   |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  10.432 [187]  |■■■■■■■■■■■■■■■■■■
  12.346 [247]  |■■■■■■■■■■■■■■■■■■■■■■■
  14.259 [275]  |■■■■■■■■■■■■■■■■■■■■■■■■■■
  16.173 [133]  |■■■■■■■■■■■■■
  18.087 [185]  |■■■■■■■■■■■■■■■■■■
  20.000 [421]  |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


Latency distribution:
  10% in 3.1229 secs
  25% in 5.0198 secs
  50% in 9.4596 secs
  75% in 15.3072 secs
  90% in 19.1711 secs
  95% in 19.7091 secs
  99% in 19.9749 secs
```


With 20 pods timeouts start to happen later  with more load:

```
Waiting 15 seconds for the cluster to stabilize
\nPhase 4: Load test - 30 seconds, 3200 users.

Summary:
  Total:        40.2460 secs
  Slowest:      13.6339 secs
  Fastest:      0.7814 secs
  Average:      8.7992 secs
  Requests/sec: 312.1556


Response time histogram:
  0.781 [1]     |
  2.067 [375]   |■■
  3.352 [248]   |■
  4.637 [255]   |■■
  5.922 [482]   |■■■
  7.208 [490]   |■■■
  8.493 [620]   |■■■■
  9.778 [6686]  |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■
  11.063 [2728] |■■■■■■■■■■■■■■■■
  12.349 [611]  |■■■■
  13.634 [67]   |


Latency distribution:
  10% in 5.6709 secs
  25% in 8.7648 secs
  50% in 9.3146 secs
  75% in 9.8826 secs
  90% in 10.6724 secs
  95% in 11.1127 secs
  99% in 12.0760 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.0438 secs, 0.7814 secs, 13.6339 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:    0.0005 secs, 0.0000 secs, 0.0216 secs
  resp wait:    2.9225 secs, 0.0252 secs, 9.8454 secs
  resp read:    0.1482 secs, 0.0000 secs, 1.5621 secs

Status code distribution:
  [200] 12203 responses
  [500] 360 responses



Waiting 15 seconds for the cluster to stabilize
\nPhase 5: Load test - 30 seconds, 6400 users.

Summary:
  Total:        49.8169 secs
  Slowest:      20.0157 secs
  Fastest:      0.0502 secs
  Average:      13.8072 secs
  Requests/sec: 335.8497


Response time histogram:
  0.050 [1]     |
  2.047 [597]   |■■■■■
  4.043 [440]   |■■■
  6.040 [891]   |■■■■■■■
  8.036 [840]   |■■■■■■■
  10.033 [1222] |■■■■■■■■■■
  12.029 [672]  |■■■■■
  14.026 [763]  |■■■■■■
  16.023 [641]  |■■■■■
  18.019 [1792] |■■■■■■■■■■■■■■
  20.016 [5101] |■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■


Latency distribution:
  10% in 4.5961 secs
  25% in 8.6647 secs
  50% in 16.3987 secs
  75% in 19.2860 secs
  90% in 19.6592 secs
  95% in 19.8914 secs
  99% in 20.0002 secs

Details (average, fastest, slowest):
  DNS+dialup:   0.6993 secs, 0.0502 secs, 20.0157 secs
  DNS-lookup:   0.0000 secs, 0.0000 secs, 0.0000 secs
  req write:    0.0024 secs, 0.0000 secs, 0.1609 secs
  resp wait:    1.6802 secs, 0.0255 secs, 7.9628 secs
  resp read:    0.2702 secs, 0.0000 secs, 5.3113 secs

Status code distribution:
  [200] 11368 responses
  [500] 1592 responses

Error distribution:
  [2406]        Get "http://51.143.109.195/spring-jdbc-docker/users.html": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
  [1365]        Get "http://51.143.109.195/spring-jdbc-docker/users.html": dial tcp 51.143.109.195:80: i/o timeout (Client.Timeout exceeded while awaiting headers)
```