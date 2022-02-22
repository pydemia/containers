# Workaround

conditional copy using `ARG`:

```dockerfile
FROM python:3.8

ARG GIVEN_PIP_CONFIG_FILE
ENV PIP_CONFIG_FILE=${GIVEN_PIP_CONFIG_FILE:+/workspace/pip.conf}

COPY $GIVEN_PIP_CONFIG_FILE $PIP_CONFIG_FILE
```

Test 1: if `pip.conf` is given:
```bash
$ docker build . -f dummy.Dockerfile -t dummy \
  --build-arg GIVEN_PIP_CONFIG_FILE=pip.conf

$ docker run --rm -it --entrypoint bash dummy.Dockerfile

> echo $PIP_CONFIG_FILE
/workspace/pip.conf
```

Test 2: if `pip.conf` is null:
```bash
$ docker build . -f dummy.Dockerfile -t dummy

$ docker run --rm -it --entrypoint bash dummy.Dockerfile

> echo $PIP_CONFIG_FILE

```
