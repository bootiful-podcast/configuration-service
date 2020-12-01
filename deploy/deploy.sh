#!/usr/bin/env bash

export ROOT_DIR=$(cd $(dirname $0) && pwd)
export BP_MODE_LOWERCASE=${BP_MODE_LOWERCASE:-development}
export OD=${ROOT_DIR}/overlays/${BP_MODE_LOWERCASE}
export APP_NAME=configuration
export SECRETS=${APP_NAME}-secrets
export SECRETS_FN=${OD}/${APP_NAME}-secrets.env

mkdir -p $(dirname $SECRETS_FN)
touch $SECRETS_FN

export RESERVED_IP_NAME=configuration-${BP_MODE_LOWERCASE}-ip
gcloud compute addresses list --format json | jq '.[].name' -r | grep $RESERVED_IP_NAME ||
  gcloud compute addresses create $RESERVED_IP_NAME --global

echo writing to "$SECRETS_FN "
cat <<EOF >${SECRETS_FN}
GIT_PASSWORD=${GIT_PASSWORD}
GIT_USERNAME=${GIT_USERNAME}
CONFIGURATION_SERVER_USERNAME=${CONFIGURATION_SERVER_USERNAME}
CONFIGURATION_SERVER_PASSWORD=${CONFIGURATION_SERVER_PASSWORD}
SPRING_PROFILES_ACTIVE=cloud
EOF

kubectl apply -k ${OD}

rm $SECRETS_FN
