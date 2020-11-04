#!/usr/bin/env bash

function resolve_variable_by_mode(){
  NV=${1}_${BP_MODE}
  INDIRECT_VALUE=${!NV}
  echo $NV
  T=$RANDOM
  echo ${INDIRECT_VALUE} >> $T
  echo ${1}="$(cat $T)" >> $GITHUB_ENV
}

function install_gacc() {
  mkdir -p $GITHUB_WORKSPACE/bin
  export PATH=$PATH:$GITHUB_WORKSPACE/bin

  ORGANIZATION=joshlong
  REPO=github-actions-config-client
  LOCATION=$( \
  curl -s https://api.github.com/repos/$ORGANIZATION/$REPO/releases/latest | \
   jq  '.assets[0].browser_download_url' -r )

  wget $LOCATION

  chmod a+x gacc
  mv gacc $GITHUB_WORKSPACE/bin/gacc
}