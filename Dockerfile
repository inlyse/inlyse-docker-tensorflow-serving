ARG TF_SERVING_VERSION=latest
ARG TF_SERVING_BUILD_IMAGE=inlyse/tensorflow-serving:${TF_SERVING_VERSION}-devel
ARG OPENSUSE_VERSION=15.2

FROM ${TF_SERVING_BUILD_IMAGE} as build_image
FROM opensuse/leap:${OPENSUSE_VERSION}  as base_build

ARG TF_SERVING_VERSION_GIT_BRANCH=master
ARG TF_SERVING_VERSION_GIT_COMMIT=head

LABEL maintainer="Inlyse UG (haftungsbeschränkt) <info@inlyse.com>"
LABEL org.opencontainers.image.title="Inlyse Tensorflow Serving Container"
LABEL org.opencontainers.image.authors="Inlyse UG (haftungsbeschränkt)"
LABEL org.opencontainers.image.source="https://github.com/inlyse/inlyse-docker-tensorflow-serving"
LABEL org.opencontainers.image.url="https://hub.docker.com/repository/docker/inlyse/tensorflow-serving"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.description="Image containing tensorflow serving"
LABEL org.google.tensorflow.serving.branch=${TF_SERVING_VERSION_GIT_BRANCH}
LABEL org.google.tensorflow.serving.commit=${TF_SERVING_VERSION_GIT_COMMIT}
LABEL org.opensuse.version="15.2"

RUN zypper -n ref && zypper -n up && zypper -n in \
        ca-certificates \
        && \
    zypper -n clean

# Install TF Serving pkg
COPY --from=build_image /usr/local/bin/tensorflow_model_server /usr/bin/tensorflow_model_server

# Expose ports
# gRPC
EXPOSE 8500

# REST
EXPOSE 8501

# Set where models should be stored in the container
ENV MODEL_BASE_PATH=/models
RUN mkdir -p ${MODEL_BASE_PATH}

# The only required piece is the model name in order to differentiate endpoints
ENV MODEL_NAME=model

# Create a script that runs the model server so we can use environment variables
# while also passing in arguments from the docker command line
RUN echo '#!/bin/bash \n\n\
tensorflow_model_server --port=8500 --rest_api_port=8501 \
--model_name=${MODEL_NAME} --model_base_path=${MODEL_BASE_PATH}/${MODEL_NAME} \
"$@"' > /usr/bin/tf_serving_entrypoint.sh \
&& chmod +x /usr/bin/tf_serving_entrypoint.sh

ENTRYPOINT ["/usr/bin/tf_serving_entrypoint.sh"]
