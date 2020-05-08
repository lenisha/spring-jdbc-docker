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
docker run --rm -it -p 8080:8080 -e JAVA_OPTS="$JAVA_OPTS"  spring-jdbc-docker
```

```
export SQL_URL="jdbc:sqlserver://testmetoday.database.windows.net:1433;database=testae;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
export SQL_PASSWORD=xxx
export SQL_USER=todayadmin@testmetoday
export JAVA_OPTS="-DSQL_URL='$SQL_URL' -DSQL_USER=$SQL_USER -DSQL_PASSWORD=$SQL_PASSWORD"

```

# K8S

```
kubectl create secret generic sqlpass --from-literal=SQL_PASS=xxxx
kubectl apply -f 
```

```
curl http://51.143.109.195/spring-jdbc-docker/users.html
```