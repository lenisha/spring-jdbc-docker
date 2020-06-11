
FROM frolvlad/alpine-glibc
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
#RUN ZULU_ARCH=zulu8.46.0.19-ca-jdk8.0.252-linux_x64.tar.gz && \

RUN ZULU_ARCH=zulu8.21.0.1-jdk8.0.131-linux_x64.tar.gz && \
	INSTALL_DIR=/usr/lib/jvm && \
	BIN_DIR=/usr/bin && \
	MAN_DIR=/usr/share/man/man1 && \
	ZULU_DIR=$( basename ${ZULU_ARCH} .tar.gz ) && \
	apk update && \
	apk add --no-cache ca-certificates wget && \
	update-ca-certificates && \
	wget -q http://cdn.azul.com/zulu/bin/${ZULU_ARCH} && \
	mkdir -p ${INSTALL_DIR} && \
	tar -xf ./${ZULU_ARCH} -C /usr/lib/jvm/ && rm -f ${ZULU_ARCH} && \
	cd ${BIN_DIR}; find ${INSTALL_DIR}/${ZULU_DIR}/bin -type f -perm -a=x -exec ln -s {} . \; && \
	mkdir -p ${MAN_DIR} && \
	cd ${MAN_DIR}; find ${INSTALL_DIR}/${ZULU_DIR}/man/man1 -type f -name "*.1" -exec ln -s {} . \; && \
	java -version 
RUN java -version

####### INSTALL TOMCAT
# Environment variables
ENV TOMCAT_MAJOR=7 \
    TOMCAT_VERSION=7.0.59 \
    CATALINA_HOME=/opt/tomcat

# init
RUN apk -U upgrade --update && \
    apk add curl && \
    apk add ttf-dejavu

RUN mkdir -p /opt

# install tomcat
RUN curl -jkSL -o /tmp/apache-tomcat.tar.gz http://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    gunzip /tmp/apache-tomcat.tar.gz && \
    tar -C /opt -xf /tmp/apache-tomcat.tar && \
    ln -s /opt/apache-tomcat-$TOMCAT_VERSION $CATALINA_HOME


WORKDIR $CATALINA_HOME

# install AppDynamics agent
COPY lib/AppServerAgent-20.4.0.29862.zip ./AppServerAgent-20.4.0.29862.zip 
   
RUN mkdir /opt/tomcat/appDynamics && \
    unzip ./AppServerAgent-20.4.0.29862.zip -d /opt/tomcat/appDynamics && \
    rm -f ./AppServerAgent-20.4.0.29862.zip

# cleanup
RUN apk del curl && \
    rm -rf /tmp/* /var/cache/apk/*

# install Application
EXPOSE 8080
# Tomcat Config
COPY config/startup.sh /opt/startup.sh
COPY target/spring-jdbc-docker/WEB-INF/lib/mssql-jdbc-7.4.1.jre8.jar /opt/apache-tomcat-7.0.59/lib/mssql-jdbc-7.4.1.jre8.jar
ADD  config/tomcat-users.xml config/server.xml $CATALINA_HOME/conf/

# Application
RUN mkdir /opt/apache-tomcat-7.0.59/webapps/spring-jdbc-docker

ADD target/spring-jdbc-docker/ /opt/apache-tomcat-7.0.59/webapps/spring-jdbc-docker/

ENTRYPOINT /opt/startup.sh
