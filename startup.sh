#!/bin/sh

#export JAVA_OPTS="-Djava.io.tmpdir=/mnt/azure/${MY_POD_NAME} $JAVA_OPTS"
echo "JAVA OPTS ====== $JAVA_OPTS  ===="

#export CATALINA_OPTS="-Djava.io.tmpdir=/mnt/azure/${MY_POD_NAME} $CATALINA_OPTS"
echo "CATALINA_OPTS ===== $CATALINA_OPTS ======"

mkdir /mnt/azure/${MY_POD_NAME}  
# start the tomcat
$CATALINA_HOME/bin/catalina.sh run