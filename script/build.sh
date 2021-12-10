#!/bin/sh
set -eux

NAME=${1}
VERSION=${2:-latest}
IMAGE="${REGISTRY_HOST}/${REGISTRY_NAMESPACE}/docker-lnmp-${NAME}:${VERSION}"

cd "${NAME}"

docker build --force-rm --compress --file Dockerfile --tag "${IMAGE}" .
docker login "${REGISTRY_HOST}" -u "${REGISTRY_USERNAME}" -p "${REGISTRY_USERNAME}"
docker push "${IMAGE}"

cd -
