FROM riyazshaik007/mytomcat:latest
LABEL maintainer="riyazshaik"
ADD ./target/EMS-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/
EXPOSE 8090
CMD ["catalina.sh", "run"]
