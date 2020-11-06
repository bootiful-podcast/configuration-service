#!/usr/bin/env bash

export APP_NAME=${APP_NAME:-configuration}
ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
APP_YAML=${ROOT_DIR}/deploy/bp-configuration.yaml
APP_SERVICE_YAML=${ROOT_DIR}/deploy/bp-configuration-service.yaml
SECRETS=${APP_NAME}-secrets

kubectl delete secrets ${SECRETS} || echo "could not delete ${SECRETS}."
kubectl delete -f $APP_YAML || echo "could not delete the existing Kubernetes environment as described in ${APP_YAML}."
kubectl apply -f <(echo "
---
apiVersion: v1
kind: Secret
metadata:
  name: ${SECRETS}
type: Opaque
stringData:
  GIT_PASSWORD : ${GIT_PASSWORD}
  GIT_USERNAME: ${GIT_USERNAME}
  CONFIGURATION_SERVER_USERNAME: ${CONFIGURATION_SERVER_USERNAME}
  CONFIGURATION_SERVER_PASSWORD: ${CONFIGURATION_SERVER_PASSWORD}
  SPRING_PROFILES_ACTIVE: cloud
")

## todo need some way to parameterize this yaml for the DNS URI
kubectl apply -f $APP_YAML
kubectl get service | grep $APP_NAME || kubectl apply -f $APP_SERVICE_YAML
