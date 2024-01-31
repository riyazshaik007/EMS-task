FROM varakumar/mytomcat:latest
LABEL maintainer="vara kumar"
ADD ./*.war /usr/local/tomcat/webapps/
EXPOSE 8090
CMD ["catalina.sh", "run"]
