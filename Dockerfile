FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
COPY scripts/ scripts/
RUN chmod -R +x scripts && ./scripts/provision.sh
