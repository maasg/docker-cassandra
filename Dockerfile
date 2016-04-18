##
##    Install Datastax Enterprise
##

FROM ubuntu
MAINTAINER Gerard Maas  gerard.maas@gmail.com


# Add PPA for the necessary JDK
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
RUN apt-get update

# Install other packages
RUN apt-get install -y curl

# Preemptively accept the Oracle License
RUN echo "oracle-java7-installer	shared/accepted-oracle-license-v1-1	boolean	true" > /tmp/oracle-license-debconf
RUN /usr/bin/debconf-set-selections /tmp/oracle-license-debconf
RUN rm /tmp/oracle-license-debconf

# Install the JDK
RUN apt-get install -y oracle-java8-installer oracle-java8-set-default
RUN apt-get install -y apt-transport-https
RUN apt-get update

# Install Datastax Enterprise
RUN echo "deb https://<DATASTAXUSER>:<PASSWORD>@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
RUN curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
RUN apt-get update
RUN sudo apt-get install -y dse-full

#Install spark-notebook

ENV NOTEBOOK_VERSION=spark-notebook-0.6.3-scala-2.10.4-spark-1.5.2-hadoop-2.6.0
ENV NOTEBOOK_FILE="${NOTEBOOK_VERSION}.tgz"
RUN wget https://s3.eu-central-1.amazonaws.com/spark-notebook/tgz/$NOTEBOOK_FILE
RUN tar -xvf $NOTEBOOK_FILE -C /opt/
RUN rm $NOTEBOOK_FILE

#Copy relevant notebooks onto the docker image

ADD notebooks /opt/$NOTEBOOK_VERSION/notebooks

# Start the datastax-agent
RUN service datastax-agent start

# Deploy startup script
ADD init.sh /usr/local/bin/cass-dock
RUN chmod 755 /usr/local/bin/cass-dock

# Deploy shutdown script
ADD shutdown.sh /usr/local/bin/cass-stop
RUN chmod 755 /usr/local/bin/cass-stop

EXPOSE 7199 7000 7001 9160 9042 9000 4040 4041 4042 4043 4044
USER root
CMD cass-dock
