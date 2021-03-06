#!/usr/bin/env bash

image_id=$(docker images -q $APP_NAME)
docker rmi -f $image_id || echo "there is not an existing image to delete..."
mvn -DskipTests=true -f $GITHUB_WORKSPACE/pom.xml clean spring-boot:build-image
image_id=$(docker images -q $APP_NAME)
docker tag "${image_id}" gcr.io/${GCLOUD_PROJECT}/${APP_NAME}
docker push gcr.io/${GCLOUD_PROJECT}/${APP_NAME}