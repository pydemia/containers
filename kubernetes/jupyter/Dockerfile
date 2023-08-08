ARG PLATFORM_ARCH="linux/amd64"
ARG USER_PASSWD="Jupyter!"
# ARG BASE_IMAGE="corus.azurecr.io/apps/corus-base:latest"
ARG BASE_IMAGE="jupyter/datascience-notebook:latest"

FROM --platform=${PLATFORM_ARCH} ${BASE_IMAGE}

ENV NB_USER_PASSWD="${USER_PASSWD}"

USER root
# RUN echo "${NB_USER}:${NB_USER_PASSWD}" | chpasswd && adduser ${NB_USER} sudo
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER ${NB_USER}
