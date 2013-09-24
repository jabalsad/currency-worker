#!/bin/bash

WORKER_HOME="$HOME/currency-worker"

today=$(date +%Y-%m-%d)
logdir="$WORKER_HOME/var/log"
logfile="$logdir/currency-worker.log.$today"

mkdir -p $logdir
pushd $WORKER_HOME
bundle exec ruby -I lib bin/currency-worker.rb | tee -a $logfile
popd