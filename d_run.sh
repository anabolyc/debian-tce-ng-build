#!/bin/bash

docker run --rm --privileged -ti -v /media/storage-unprotected/live-default:/live-default $(cat tag) /bin/bash
