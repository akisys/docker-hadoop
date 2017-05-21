NAME = akisys/hadoop
VERSION = 2.8.0

EXAMPLES = "/usr/local/hadoop/share/hadoop/mapreduce"

.PHONY: all build run

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .

deploy: build
	docker push $(NAME):$(VERSION)

nn:
	docker run -it --name $@ -p 50070:50070 -h hdfs-namenode -v /tmp/docker/hdfs:/hdfs $(NAME):$(VERSION) /entrypoint.sh hdfs namenode
	docker rm $@

snn:
	docker run -it --name $@ --link=nn:hdfs-namenode -v /tmp/docker/hdfs:/hdfs $(NAME):$(VERSION) /entrypoint.sh hdfs secondarynamenode
	docker rm $@

dn:
	docker run -it --name $@ --link=nn:hdfs-namenode -v /tmp/docker/hdfs:/hdfs $(NAME):$(VERSION) /entrypoint.sh hdfs datanode
	docker rm $@

yrm:
	docker run -it --name $@ -p 8088:8088 -h yarn-resourcemanager -v /tmp/docker/hdfs:/hdfs $(NAME):$(VERSION) /entrypoint.sh yarn resourcemanager
	docker rm $@

ynm:
	docker run -it --name $@ -h $@ -p 8042:8042 --link=nn:hdfs-namenode --link=yrm:yarn-resourcemanager -v /tmp/docker/hdfs:/hdfs $(NAME):$(VERSION) /entrypoint.sh yarn nodemanager
	docker rm $@

hist:
	docker run -it --name $@ -p 19888:19888 --link=nn:hdfs-namenode -v /tmp/docker/hdfs:/hdfs $(NAME):$(VERSION) /entrypoint.sh mapred historyserver
	docker rm $@

testrun:
	docker run -it --name $@ --link=ynm:yarn-nodemanager --link=nn:hdfs-namenode --link=yrm:yarn-resourcemanager $(NAME):$(VERSION) hadoop jar $(EXAMPLES)/hadoop-mapreduce-examples-2.8.0.jar pi 16 1000
	docker rm $@

runit:
	docker run -it --name $@ --link=ynm:yarn-nodemanager --link=nn:hdfs-namenode --link=yrm:yarn-resourcemanager $(NAME):$(VERSION) /bin/bash
	docker rm $@

