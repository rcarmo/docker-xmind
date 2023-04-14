export IMAGE_NAME?=rcarmo/xmind
export VCS_REF=`git rev-parse --short HEAD`
export VCS_URL=https://github.com/rcarmo/docker-xmind
export BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"`
export TAG_DATE=`date -u +"%Y%m%d"`
export TARGET_ARCHITECTURES=amd64
export SHELL=/bin/bash

build:
	@echo "--> Building container"
	docker build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VCS_URL=$(VCS_URL) \
		-t $(IMAGE_NAME):latest .
	@echo "--> Done building container"


clean:
	-docker rm -v $$(docker ps -a -q -f status=exited)
	-docker rmi $$(docker images -q -f dangling=true)
	-docker rmi $$(docker images --format '{{.Repository}}:{{.Tag}}' | grep '$(IMAGE_NAME)')

push:
	docker push $(IMAGE_NAME)

test:
	docker run \
		--name=xmind \
		-e PUID=1000 \
		-e PGID=1000 \
		-e TZ=Europe/Lisbon \
		-e PASSWORD='test' \
		-e CLI_ARGS='' \
		-p 8080:8080 \
		--restart unless-stopped \
		-ti $(IMAGE_NAME)

kill:
	docker kill xmind ; docker rm xmind