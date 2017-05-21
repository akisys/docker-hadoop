#!/bin/bash

set -e

function hdfs_entrypoint() {
  source $HADOOP_CONF_DIR/hadoop-env.sh
  case "${_sub}" in
    namenode)
      mkdir -p $HADOOP_HDFS_DATA_NAMEDIR
      if [ ! -d "${HADOOP_HDFS_DATA_NAMEDIR}/current" ];
      then
        hdfs namenode -format
      fi
      ;;
    secondarynamenode)
      mkdir -p $HADOOP_HDFS_DATA_SECONDARYNAMEDIR
      ;;
    datanode)
      mkdir -p $HADOOP_HDFS_DATADIR
      ;;
    *)
      echo "unrecognised subcommand"
      exit 1
      ;;
  esac
  run
}

function yarn_entrypoint() {
  source $YARN_CONF_DIR/yarn-env.sh
  case "${_sub}" in
    resourcemanager|nodemanager)
      mkdir -p $YARN_LOG_DIR
      ;;
    *)
      echo "unrecognised subcommand"
      exit 1
      ;;
  esac
  run
}

function mapred_entrypoint() {
  source $HADOOP_CONF_DIR/mapred-env.sh
  case "${_sub}" in
    historyserver)
      mkdir -p $HADOOP_MAPRED_LOG_DIR
      ;;
    *)
      echo "unrecognised subcommand"
      exit 1
      ;;
  esac
  run
}

function run() {
  set +e
  service ssh start
  $_cmd $_sub
}

_default_cmd="version"

while [ -n "${1}" ] || [ -n "${_default_cmd}" ];
do
  _cmd="${1:-$_default_cmd}"
  case "${_cmd}" in
    hdfs)
      shift
      _sub="${1}"
      hdfs_entrypoint
      break
      ;;
    yarn)
      shift
      _sub="${1}"
      yarn_entrypoint
      break
      ;;
    mapred)
      shift
      _sub="${1}"
      mapred_entrypoint
      break
      ;;
    "version")
      hadoop version
      exit 0
      ;;
    *)
      echo "NO CMD"
      exit 1
      ;;
  esac
done

