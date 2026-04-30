FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y bash
RUN apt-get install -y bash-completion
RUN apt-get install -y coreutils
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y gzip
RUN apt-get install -y git
RUN apt-get install -y sudo
RUN apt-get install -y tar
RUN apt-get install -y stow

# Grant the built-in 'ubuntu' user (UID/GID 1000) passwordless sudo.
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
    && chmod 0440 /etc/sudoers.d/ubuntu

USER ubuntu
