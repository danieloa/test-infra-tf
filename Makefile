# Makefile for danieloa-infrastructure-tf

.PHONY: all build install init plan-vpc apply-vpc plan-core apply-core plan-apps apply-apps destroy-vpc destroy-core destroy-apps clean

all: build

# Build the deploy CLI tool
build:
	go build -o bin/deploy ./cmd/deploy

# Install the deploy CLI tool to $GOPATH/bin
install:
	go install ./cmd/deploy

# Initialize S3 state backend bucket using CLI tool
init: build
	./bin/deploy init

# Plan stages using CLI tool
plan-vpc: build
	./bin/deploy vpc --action plan

plan-core: build
	./bin/deploy core --action plan

plan-apps: build
	./bin/deploy apps --action plan

# Deploy stages using CLI tool
deploy-vpc: build
	./bin/deploy vpc --action apply

deploy-core: build
	./bin/deploy core --action apply

deploy-apps: build
	./bin/deploy apps --action apply

# Deploy all stages in order
deploy: deploy-vpc deploy-core deploy-apps

# Destroy stages in reverse order
destroy-apps: build
	./bin/deploy apps --action destroy

destroy-core: build
	./bin/deploy core --action destroy

destroy-vpc: build
	./bin/deploy vpc --action destroy

destroy: destroy-apps destroy-core destroy-vpc

clean:
	rm -rf bin/ deploy
