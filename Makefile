current_dir:=$(shell pwd)
build_tag = 'squid3-ssl-build'
image_name = squid3-ssl

REGISTRY ?= dev-docker.points.com:80
TAG ?= $(shell date +%Y%m%d)
SQUID_RELEASE ?= 'https://s3.amazonaws.com/cirrus-ami-builds/public/squid3-20161115.tgz'
SQUID_MD5 ?= '22b12e60d04a326ff359f7188fb3ab65'

.PHONY: debs build_debs copy_debs

debs: build_debs copy_debs
image: build_image push_image

build_debs:
	docker build -t $(build_tag) - < Dockerfile.build

copy_debs:
	@mkdir -p debs
	docker run -v $(current_dir)/debs:/src/debs $(build_tag) /bin/sh -c 'cp /src/*.deb /src/debs/'

release_debs:
	sudo chown ${USER}:${USER} debs/*
	tar -zcvf squid3-$(shell date +%Y%m%d).tgz debs/

build_image:
	docker-1.9.1 build -t $(REGISTRY)/$(image_name):$(TAG) --build-arg SQUID_RELEASE=$(SQUID_RELEASE) --build-arg SQUID_MD5=$(SQUID_MD5)  .

push_image:
	docker-1.9.1 push $(REGISTRY)/$(image_name):$(TAG)