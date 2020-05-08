#!/bin/sh

echo $JAVA_OPTS
echo $CATALINA_OPTS

# start the tomcat
$CATALINA_HOME/bin/catalina.sh run