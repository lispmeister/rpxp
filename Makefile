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
	docker run --rm $(DOCKER_IMAGE_TAGNAME) rpxp-ponyc --version

exited := $(shell docker ps -a -q -f status=exited)
untagged := $(shell (docker images | grep "^<none>" | awk -F " " '{print $$3}'))
dangling := $(shell docker images -f "dangling=true" -q)

clean:
ifneq ($(strip $(exited)),)
	@echo "Cleaning exited containers: $(exited)"
	docker rm -v $(exited)
endif
# ifneq ($(strip $(untagged)),)
# 	@echo "Cleaning untagged images: $(untagged)"
# 	docker rmi $(untagged)
# endif
ifneq ($(strip $(dangling)),)
	@echo "Cleaning dangling images: $(dangling)"
	docker rmi $(dangling)
endif
	@echo 'Done cleaning.'
