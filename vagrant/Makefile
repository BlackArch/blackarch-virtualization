BUILD_DIR ?= ./output
TEST_DIR ?= ./testing
BOX_NAME ?= blackarch
PROVIDER ?= virtualbox
BOX_FILENAME ?= $(BOX_NAME)_$(PROVIDER).box
BOX_DEFINITION ?= ./template.json
PACKER ?= packer-io

.PHONY: all clean deepclean validate build update

all: build

build: $(BUILD_DIR)/$(BOX_FILENAME)

update:
	scripts/update.sh

clean:
	rm -rf $(BUILD_DIR)
	( cd $(TEST_DIR)        && \
	    vagrant destroy -f && \
	    cd .. ) || true
	rm -rf $(TEST_DIR)
	rm -f *.{hwm,pwd,pwi}

deepclean: clean
	rm -rf ./packer_cache

validate:
	$(PACKER) validate $(BOX_DEFINITION)

$(BUILD_DIR)/$(BOX_FILENAME): validate
	$(PACKER) build -var 'git_revision=$(shell git rev-parse --abbrev-ref HEAD):$(shell git rev-parse --verify HEAD)' $(BOX_DEFINITION)

test: 
	echo $(BUILD_DIR)/$(BOX_FILENAME)
	vagrant box add --force $(BOX_NAME) $(BUILD_DIR)/$(BOX_FILENAME) && \
	  mkdir -pv $(TEST_DIR) && \
	  cd $(TEST_DIR) && \
	  ( vagrant destroy -f || true ) && \
	  ( rm ./Vagrantfile || true ) && \
	  vagrant init --minimal $(BOX_NAME) && \
	  vagrant up && \
	  ( vagrant ssh -c "uname -a" | grep Linux | grep -q ARCH ) && echo TEST OK: Can connect to VM. || echo TEST FAIL: VM connect && \
	  ( vagrant ssh -c "ls /vagrant" | grep -q Vagrantfile ) && echo TEST OK: Shared folders are mounted in VM. || echo TEST FAIL: Shared folders. && \
	  vagrant destroy -f
