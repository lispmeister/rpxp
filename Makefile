DOCKER_IMAGE_VERSION=0.0.1
DOCKER_IMAGE_NAME=lispmeister/rpxp
DOCKER_IMAGE_TAGNAME=$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)

default: build

print-%  : ; @echo $* = $($*)

build:
	docker build -t $(DOCKER_IMAGE_TAGNAME) .
	docker tag -f $(DOCKER_IMAGE_TAGNAME) $(DOCKER_IMAGE_NAME):latest

push:
	docker push $(DOCKER_IMAGE_NAME)

test:
	docker run --rm $(DOCKER_IMAGE_TAGNAME) echo 'Success.'

version:
	ponyc --version


exited := $(shell docker ps -a -q -f status=exited)
untagged := $(shell (docker images | grep "^<none>" | awk -F " " '{print $$3}'))
dangling := $(shell docker images -f "dangling=true" -q)
tag := $(shell docker images | grep "$(DOCKER_IMAGE_NAME)" | grep "$(DOCKER_IMAGE_VERSION)" |awk -F " " '{print $$3}')
latest := $(shell docker images | grep "$(DOCKER_IMAGE_NAME)" | grep "latest" | awk -F " " '{print $$3}')

clean:
ifneq ($(strip $(latest)),)
	@echo "Removing latest $(latest) image"
	docker rmi "$(DOCKER_IMAGE_NAME):latest"
endif
ifneq ($(strip $(tag)),)
	@echo "Removing tag $(tag) image"
	docker rmi "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)"
endif
ifneq ($(strip $(exited)),)
	@echo "Cleaning exited containers: $(exited)"
	docker rm -v $(exited)
endif
ifneq ($(strip $(dangling)),)
	@echo "Cleaning dangling images: $(dangling)"
	docker rmi $(dangling)
endif
	@echo 'Done cleaning.'
