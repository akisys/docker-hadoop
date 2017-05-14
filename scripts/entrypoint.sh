#!/bin/bash

source $HADOOP_CONF_DIR/hadoop-env.sh

_default_cmd="version"

while [ -n "${1}" ] || [ -n "${_default_cmd}" ];
do
  _cmd="${1:-$_default_cmd}"
  case "${_cmd}" in
    hdfs|yarn|mapred)
      shift
      _sub="${1}"
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

service ssh start
$_cmd $_sub
