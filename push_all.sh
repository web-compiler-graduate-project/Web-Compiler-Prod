#!/bin/bash

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found."
    exit 1
fi

LOCAL_IMAGES=("web-compiler-backend" "web-compiler-frontend" "web-compiler-message-publisher" "web-compiler-nginx")
TAG="latest"

echo "Logging in to Docker Hub..."
docker login -u "$DOCKER_USERNAME" -p "$DOCKER_PASSWORD"
if [ $? -ne 0 ]; then
    echo "Login failed."
    exit 1
fi

for LOCAL_IMAGE in "${LOCAL_IMAGES[@]}"; do
    NEW_IMAGE="$REPO_PREFIX:$(basename $LOCAL_IMAGE)"

    echo "Tagging image: $LOCAL_IMAGE:$TAG as $NEW_IMAGE"
    docker tag "$LOCAL_IMAGE:$TAG" "$NEW_IMAGE"

    if [ $? -ne 0 ]; then
        echo "Failed to tag image $LOCAL_IMAGE:$TAG as $NEW_IMAGE."
        exit 1
    fi

    echo "Pushing image: $NEW_IMAGE"
    docker push "$NEW_IMAGE"

    if [ $? -ne 0 ]; then
        echo "Failed to push image $NEW_IMAGE."
        exit 1
    fi
done

echo "All images have been successfully pushed."
