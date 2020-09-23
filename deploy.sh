#!/bin/bash
TAG=jonaskop/registry_cleaner
docker build . -t $TAG
docker push $TAG
