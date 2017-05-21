FROM openjdk:8-jdk

USER root

ENV JAVA_HOME /docker-java-home
ENV HADOOP_VERSION 2.8.0

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server aria2 libzip2 libsnappy1 libssl-dev && \
    aria2c http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz && \
    apt-get remove -y aria2 && \
    rm -rf /var/lib/apt/lists/* && \
    tar -zxf /hadoop-$HADOOP_VERSION.tar.gz && \
    rm /hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION /usr/local/hadoop

ADD system-conf/sshd_config /etc/ssh/sshd_config
ADD system-conf/ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config

# passwordless ssh
RUN ssh-keygen -q -N "" -t rsa -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME $HADOOP_PREFIX
ENV HADOOP_HDFS_HOME $HADOOP_PREFIX
ENV HADOOP_MAPRED_HOME $HADOOP_PREFIX
ENV HADOOP_YARN_HOME $HADOOP_PREFIX
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV HADOOP_CONF_DIR $HADOOP_PREFIX/etc/hadoop

ENV HADOOP_OPTS -Djava.library.path=$HADOOP_PREFIX/lib/native
ENV PATH $PATH:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin

# Hdfs ports
EXPOSE 50010 50020 50070 50075 50090 8020 9000
# Mapred ports
EXPOSE 10020 19888
#Yarn ports
EXPOSE 8030 8031 8032 8033 8040 8042 8088
#Other ports
EXPOSE 49707 2122

######################
VOLUME /hdfs

ENV HADOOP_HDFS_DIR /hdfs
ENV HADOOP_HDFS_DATADIR $HADOOP_HDFS_DIR/data
ENV HADOOP_HDFS_DATA_NAMEDIR $HADOOP_HDFS_DIR/name
ENV HADOOP_HDFS_DATA_SECONDARYNAMEDIR $HADOOP_HDFS_DIR/namesecondary
ENV HADOOP_HDFS_DATA_LOGDIR $HADOOP_HDFS_DIR/logs
ENV YARN_LOG_DIR $HADOOP_HDFS_DATA_LOGDIR
ENV HADOOP_MAPRED_LOG_DIR $HADOOP_HDFS_DATA_LOGDIR

COPY hadoop-conf $HADOOP_CONF_DIR
RUN  chmod +x $HADOOP_CONF_DIR/*-env.sh

ADD scripts/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
