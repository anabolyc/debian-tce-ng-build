#!/bin/bash

docker run --rm -ti -v /media/storage-unprotected/live-default:/live-default $(cat tag) /bin/bash
