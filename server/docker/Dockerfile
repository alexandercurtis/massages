FROM ubuntu:14.04

RUN apt-get update
RUN apt-get -y install openjdk-7-jre
ENV APP_ENV=production

ADD ./massage-server-0.1.0-SNAPSHOT-standalone.jar /root/massage-server.jar

EXPOSE 3000
CMD "/usr/bin/java" "-jar" "/root/massage-server.jar"
