FROM debian:jessie

# reqired packages
RUN apt-get update && \
	apt-get install nano cpio genisoimage git-core live-build live-config-doc live-manual-html live-boot-doc -y --no-install-recommends && \
	rm -rf /var/lib/apt/lists/*

# prepare fs
RUN mkdir /live-build-scripts
COPY ./live-build-scripts/*.sh /live-build-scripts/
COPY start.sh /live-build-scripts/

RUN mkdir /live-default
WORKDIR /live-default

CMD ["/bin/bash", "/live-build-scripts/start.sh"]
