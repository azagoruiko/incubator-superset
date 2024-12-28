DOCKER_REPO="10.8.0.5:5000"
VER=0.0.13
export NOMAD_ADDR="http://10.8.0.1:4646"
if [ ! -e $1 ]; then
    VER=$1
fi
export VER
echo $VER
DOCKER_TAG="${DOCKER_REPO}/superset:${VER}"
echo $DOCKER_TAG

docker build -t "$DOCKER_TAG" -f Dockerfile .
docker push "$DOCKER_TAG"

nomad job run contrib/nomad/superset.nomad
