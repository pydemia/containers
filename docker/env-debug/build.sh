#!/usr/bin/env bash

docker build . -f debug-slim.Dockerfile -t pydemia/debug-slim:latest
docker build . -f debug.Dockerfile -t pydemia/debug:latest
docker build . -f debug-alpine-slim.Dockerfile -t pydemia/debug-alpine-slim:latest
docker build . -f debug-alpine.Dockerfile -t pydemia/debug-alpine:latest

docker push pydemia/debug-slim:latest
docker push pydemia/debug:latest
docker push pydemia/debug-alpine-slim:latest
docker push pydemia/debug-alpine:latest
