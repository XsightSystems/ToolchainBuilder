$ErrorActionPreference = 'Stop'; # stop on all errors

$VERSION="1.23.0"
$IMAGE="toolchainbuilder"
$REPONAME="xsightsys"
$IMAGENAME="${REPONAME}/${IMAGE}"

docker pull ubuntu:16.04 
if ($LastExitCode -ne 0) {throw 'docker build failed'};`
docker build -t ${IMAGENAME}:latest --build-arg VERSION=${VERSION} . 
if ($LastExitCode -ne 0) {throw 'docker build failed'}`
docker tag ${IMAGENAME}:latest ${IMAGENAME}:${VERSION} 
if ($LastExitCode -ne 0) {throw 'docker build failed'}`
docker login
if ($LastExitCode -ne 0) {throw 'docker build failed'}`
docker push ${IMAGENAME}:latest
if ($LastExitCode -ne 0) {throw 'docker build failed'}`
docker push ${IMAGENAME}:${VERSION} 
if ($LastExitCode -ne 0) {throw 'docker build failed'}`
