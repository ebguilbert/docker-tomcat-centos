FROM centos:7.8.2003

LABEL maintainer="Edwin Guilbert"

# ENV variables for Java
ENV JAVA_HOME /usr/lib/jvm/jre
ENV JAVA_OPTS -Djava.security.egd=file:///dev/urandom
# ENV variables for Tomcat
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.63
ENV CATALINA_HOME /opt/tomcat/apache-tomcat-$TOMCAT_VERSION
ENV CATALINA_TMPDIR /tmp/tomcat
ENV DEPLOYMENT_DIR $CATALINA_HOME/webapps
ENV PATH $PATH:$CATALINA_HOME/bin:$CATALINA_HOME/scripts

# Install Java & wget
RUN yum install -y \
       java-1.8.0-openjdk-devel \ 
       wget \
    && yum clean all

# Install Tomcat
RUN useradd -m -U -d /opt/tomcat -s /bin/false tomcat

RUN wget -q https://www.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    rm apache-tomcat*.tar.gz && \
    mv apache-tomcat* ${CATALINA_HOME}

RUN chown -R tomcat: /opt/tomcat

RUN chmod +x ${CATALINA_HOME}/bin/*sh

USER tomcat:tomcat

# Fix for JVM core dump
RUN ulimit -c unlimited

# Make sure that the temporary directory exists
RUN mkdir -p $CATALINA_TMPDIR

# Remove all webapps from the default Tomcat installation
RUN rm -rf $DEPLOYMENT_DIR/*

# Start the Tomcat instance
ENTRYPOINT ["/opt/tomcat/apache-tomcat-8.5.63/bin/catalina.sh", "run"]
CMD [""]

# Expose the ports
EXPOSE 8080