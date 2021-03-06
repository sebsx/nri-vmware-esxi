INTEGRATION  := vmware-esxi
BINARY_NAME   = nr-$(INTEGRATION)
GO_PKGS      := $(shell go list ./... | grep -v "/vendor/")
GO_FILES     := $(shell find src -type f -name "*.go")
GOTOOLS       = github.com/kardianos/govendor \
		gopkg.in/alecthomas/gometalinter.v2 \
		github.com/axw/gocov/gocov \
		github.com/AlekSi/gocov-xml \

all: build

build: clean validate test compile

clean:
	@echo "=== $(INTEGRATION) === [ clean ]: Removing binaries and coverage file..."
	@rm -rfv bin coverage.xml

tools:
	@echo "=== $(INTEGRATION) === [ tools ]: Installing tools required by the project..."
	@go get $(GOTOOLS)
	@gometalinter.v2 --install

tools-update:
	@echo "=== $(INTEGRATION) === [ tools-update ]: Updating tools required by the project..."
	@go get -u $(GOTOOLS)
	@gometalinter.v2 --install

deps: tools
	@echo "=== $(INTEGRATION) === [ deps ]: Installing package dependencies required by the project..."
	@govendor sync

validate: deps
	@echo "=== $(INTEGRATION) === [ validate ]: Validating source code running gometalinter..."
	@gometalinter.v2 --config=.gometalinter.json ./...

validate-all: deps
	@echo "=== $(INTEGRATION) === [ validate ]: Validating source code running gometalinter..."
	@gometalinter.v2 --config=.gometalinter.json --enable=interfacer --enable=gosimple ./...

compile: deps
	@echo "=== $(INTEGRATION) === [ compile ]: Building $(BINARY_NAME)..."
	@go build -o bin/$(BINARY_NAME) ./src

test: deps
	@echo "=== $(INTEGRATION) === [ test ]: Running unit tests..."
	@gocov test $(GO_PKGS) | gocov-xml > coverage.xml

.PHONY: all build clean tools tools-update deps validate compile test

