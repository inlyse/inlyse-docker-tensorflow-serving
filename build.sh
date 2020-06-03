#!/bin/bash -e

usage() { echo "Usage: $0 -v <1.15.0|2.1.0|2.2.0-rc2> -o <copt>" 1>&2; exit 1; }

while getopts ":v:o:" options; do
    case "${options}" in
        v)
            v=${OPTARG}
            [[ "x$v" == "x1.15.0" ]] || [[ "x$v" == "x2.1.0" ]] || [[ "x$v" == "x2.2.0" ]] || usage
            ;;
        o)
            o=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${v}" ]; then
    usage
else
    TF_VERSION=$v
fi

# optional --copt=-mavx512vl
if [ -z "${o}" ]; then
    BUILD_OPTIONS="--copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-msse4.1 --copt=-msse4.2"
else
    BUILD_OPTIONS=$o
fi

if [[ "$TF_VERSION" == "2.2.0-rc2" ]];then
    BAZEL_VERSION="2.0.0"
else
    BAZEL_VERSION="0.24.1"
fi

echo "Building tensorflow image for tensorflow serving ${TF_VERSION}"
echo "Using bazel ${BAZEL_VERSION} to build tensorflow"
echo "Build options ${BUILD_OPTIONS}"

read -t 10 -p "Hit ENTER or wait ten seconds"; echo

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
