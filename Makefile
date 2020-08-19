NAME     := health-planet-data-collector
VERSION  := v1.0
REVISION := $(shell git rev-parse --short HEAD)
BLDOPTS := -a -tags netgo -installsuffix netgo
LDFLAGS  := -ldflags="-s -w -X \"main.version=$(VERSION)\" -X \"main.revision=$(REVISION)\" -extldflags \"-static\""

export GO111MODULE = on

.PHONY: setup
setup:
	@:
ifeq ($(shell command -v golangci-lint 2> /dev/null),)
	go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.30.0
endif

.PHONY: deps
deps: setup
	go mod vendor

.PHONY: build
build: deps
	go build $(BLDOPTS) $(LDFLAGS) -o bin/$(NAME);

.PHONY: build-for-docker
build-for-docker: deps
	ls jobs | while read job; do \
	  GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build $(BLDOPTS) $(LDFLAGS) -o bin/$(NAME);  \
	done

.PHONY: clean
clean:
	rm -rf bin/* vendor/* dist/*

.PHONY: test
test: setup
	go test -v ./...

.PHONY: lint
lint: setup
	golangci-lint run -E stylecheck -E interfacer -E gosec -E dupl -E goconst -E gocyclo -E goimports -E maligned -E depguard -E misspell -E unparam -E prealloc -E scopelint
