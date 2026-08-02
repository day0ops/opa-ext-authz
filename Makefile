IMAGE       := opa-ext-authz
REPO        ?= australia-southeast1-docker.pkg.dev/field-engineering-apac/kasunt
VERSION     ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo dev)
PLATFORMS   := linux/amd64,linux/arm64
LOCAL_IMAGE := $(IMAGE):local

.PHONY: test
test:
	opa test policies/ -v

.PHONY: lint
lint:
	opa fmt --list --diff policies/
	opa check policies/

.PHONY: fmt
fmt:
	opa fmt -w policies/

.PHONY: docker-build
docker-build:
	docker buildx build --platform $(PLATFORMS) -t $(REPO)/$(IMAGE):$(VERSION) .

.PHONY: docker-push
docker-push:
	docker buildx build --platform $(PLATFORMS) -t $(REPO)/$(IMAGE):$(VERSION) --push .

.PHONY: release
release: docker-push

.PHONY: docker-build-local
docker-build-local:
	docker build -t $(LOCAL_IMAGE) .

.PHONY: run-local
run-local: docker-build-local
	docker run --rm -p 8181:8181 -p 9191:9191 $(LOCAL_IMAGE)
