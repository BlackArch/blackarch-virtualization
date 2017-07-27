BUILD_DIR ?= $(PWD)/output
DOCKER ?= /usr/bin/docker
DOCKER_CONTROL_SOCKET ?= /var/run/docker.sock
TAG_BUILDER ?= blackarch-builder
TAG_IMAGE ?= blackarch

.PHONY: all clean deepclean build builder image

all: build

clean:
	-$(DOCKER) rmi -f $(TAG_BUILDER)
	-rm -r $(BUILD_DIR)

deepclean: clean
	-$(DOCKER) rmi -f $(TAG_IMAGE)

build: builder image

builder:
	$(DOCKER) build -t $(TAG_BUILDER) .

image:
	$(DOCKER) run --privileged -v $(DOCKER_CONTROL_SOCKET):$(DOCKER_CONTROL_SOCKET) -v $(BUILD_DIR):/output $(TAG_BUILDER)

test:
	$(DOCKER) images | grep -q "^blackarch " || ( echo No blackarch image. && exit 1)
	$(DOCKER) run -ti blackarch echo Success.
