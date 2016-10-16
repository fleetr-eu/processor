#! /bin/sh
yarn install --production
docker build -t fleetr/processor -f Dockerfile.build .
docker push fleetr/processor
