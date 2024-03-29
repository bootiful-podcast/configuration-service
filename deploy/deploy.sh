#!/usr/bin/env bash

set -e
set -o pipefail
echo "the project is $GCLOUD_PROJECT "
export SECRETS=${APP_NAME}-secrets
export SECRETS_FN=$HOME/${SECRETS}
export IMAGE_NAME=gcr.io/${GCLOUD_PROJECT}/${APP_NAME}
export RESERVED_IP_NAME=bootiful-podcast-${APP_NAME}-ip
docker rmi -f "$IMAGE_NAME"
cd "$ROOT_DIR"
./mvnw -DskipTests=true  clean package spring-boot:build-image -Dspring-boot.build-image.imageName=$IMAGE_NAME
docker push $IMAGE_NAME
gcloud compute addresses list --format json | jq '.[].name' -r | grep $RESERVED_IP_NAME || gcloud compute addresses create $RESERVED_IP_NAME --global
touch $SECRETS_FN
echo writing to "$SECRETS_FN "
cat <<EOF >${SECRETS_FN}
GIT_PASSWORD=${GIT_PASSWORD}
GIT_USERNAME=${GIT_USERNAME}
CONFIGURATION_SERVER_USERNAME=${CONFIGURATION_SERVER_USERNAME}
CONFIGURATION_SERVER_PASSWORD=${CONFIGURATION_SERVER_PASSWORD}
SPRING_PROFILES_ACTIVE=cloud
EOF
kubectl delete secrets $SECRETS || echo "no secrets to delete."
kubectl create secret generic $SECRETS --from-env-file $SECRETS_FN
kubectl delete -f $ROOT_DIR/deploy/k8s/deployment.yaml || echo "couldn't delete the deployment as there was nothing deployed."
kubectl apply -f $ROOT_DIR/deploy/k8s