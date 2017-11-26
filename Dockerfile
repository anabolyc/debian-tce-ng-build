FROM debian:jessie

# reqired packages
RUN apt-get update && apt-get install live-build -y --no-install-recommends && rm -rf /var/lib/apt/lists/*

# prepare fs
RUN mkdir /live-build-scripts
COPY ./live-build-scripts/*.sh /live-build-scripts/
COPY start.sh /live-build-scripts/

RUN mkdir /live-default
WORKDIR /live-default

CMD ["/bin/bash", "/live-build-scripts/start.sh"]
