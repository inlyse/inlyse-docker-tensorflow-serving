TF_VERSION="1.15.0"
BAZEL_VERSION="0.24.1"
BUILD_OPTIONS="--copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-msse4.1 --copt=-msse4.2 --copt=-mavx512vl"
docker build --target clean_build \
             --build-arg TF_SERVING_VERSION_GIT_COMMIT=$TF_VERSION \
             --build-arg TF_SERVING_BUILD_OPTIONS="${BUILD_OPTIONS}" \
             --build-arg BAZEL_VERSION=$BAZEL_VERSION \
             -t inlyse/tensorflow-serving:$TF_VERSION-devel \
             -f Dockerfile.devel .
docker build --build-arg TF_SERVING_VERSION_GIT_COMMIT=TF_VERSION \
             --build-arg TF_SERVING_BUILD_IMAGE="inlyse/tensorflow-serving:$TF_VERSION-devel" \
             -t inlyse/tensorflow-serving:$TF_VERSION \
             -f Dockerfile .
