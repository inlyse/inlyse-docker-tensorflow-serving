# Docker image tensorflow serving 
This repository hosts Dockerfiles to build and distribute [tensorflow
serving](https://github.com/tensorflow/serving).

## Supported tags and respective Dockerfile links
* `1.15.0`, `latest`
* `1.15.0-devel`

## Building
**Tensorflow serving 1.15.0**
```
TF_VERSION="1.15.0"
BAZEL_VERSION="0.24.1"
BUILD_OPTIONS="--copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-msse4.1 --copt=-msse4.2"
docker build --target clean_build \
             --build-arg TF_SERVING_VERSION_GIT_COMMIT=$TF_VERSION \
             --build-arg TF_SERVING_BUILD_OPTIONS=$BUILD_OPTIONS \
             --build-arg BAZEL_VERSION=$BAZEL_VERSION \
             -t inlyse/tensorflow-serving:$TF_VERSION-devel \
             -f Dockerfile.devel .
docker build --build-arg TF_SERVING_VERSION_GIT_COMMIT=TF_VERSION \
             --build-arg TF_SERVING_BUILD_IMAGE="inlyse/tensorflow-serving:$TF_VERSION-devel" \
             -t inlyse/tensorflow-serving:$TF_VERSION \
             -f Dockerfile .
```

## Docker-compose example
```
version: '3.4'

services:
  serving:
    image: inlyse/tensorflow-serving:1.15.0
    restart: unless-stopped
    container_name: tensorflow-serving
    hostname: tf
    command: --model_config_file=/models/models.conf --port=8500 --rest_api_port=0
    environment:
      - MODEL_CONFIG_FILE_POLL_WAIT_SECONDS=60
    volumes:
      - ${TENSORFLOW_MODELS}/models:/models:Z
    ports:
      - "127.0.0.1:8500:8500"
    networks:
      internal-network:
        aliases
        - tf

networks:
  internal-network:
```
