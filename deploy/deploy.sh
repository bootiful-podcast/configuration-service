#!/usr/bin/env bash

BP_MODE=${1:-DEVELOPMENT}
echo BP_MODE=${BP_MODE}

if [ "$BP_MODE" = "DEVELOPMENT" ]; then
  echo "were using the development variables, not the production ones."
fi

function read_kubernetes_secret() {
  kubectl get secret $1 -o jsonpath="{.data.$2}" | base64 --decode
}

APP_NAME=configuration
PROJECT_ID=${GKE_PROJECT:-pgtm-jlong}
ROOT_DIR=$(cd $(dirname $0)/.. && pwd)
echo "ROOT_DIR=$ROOT_DIR"
APP_YAML=${ROOT_DIR}/deploy/bp-configuration.yaml
APP_SERVICE_YAML=${ROOT_DIR}/deploy/bp-configuration-service.yaml
SECRETS=${APP_NAME}-secrets

image_id=$(docker images -q $APP_NAME)
docker rmi -f $image_id || echo "there is not an existing image to delete..."

mvn -DskipTests=true clean spring-boot:build-image
image_id=$(docker images -q $APP_NAME)
docker tag "${image_id}" gcr.io/${PROJECT_ID}/${APP_NAME}
docker push gcr.io/${PROJECT_ID}/${APP_NAME}
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
  CONFIG_SERVICE_USERNAME: ${CONFIGURATION_SERVER_USERNAME}
  CONFIG_SERVICE_PASSWORD: ${CONFIGURATION_SERVER_PASSWORD}
  SPRING_PROFILES_ACTIVE: cloud
")

kubectl apply -f $APP_YAML

kubectl get service | grep $APP_NAME || kubectl apply -f $APP_SERVICE_YAML
