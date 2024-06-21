VENV_CMD := . venv/bin/activate &&
BASE_IMAGE=quay.io/app-sre/er-outputs-secrets

IMAGE_TAG := $(shell git describe --tags)
ifeq ($(IMAGE_TAG),)
	IMAGE_TAG = 0.0.1
endif

.PHONY: deploy
deploy: build push

.PHONY: build
build:
	docker build -t ${BASE_IMAGE}:${IMAGE_TAG} -f dockerfiles/Dockerfile .

.PHONY: push
push:
	docker push ${BASE_IMAGE}:${IMAGE_TAG}

.PHONY: dev-venv
dev-venv:
	python3.11 -m venv venv
	@$(VENV_CMD) pip install --upgrade pip
	@$(VENV_CMD) pip install -r requirements/requirements.txt
	@$(VENV_CMD) pip install -r requirements/requirements-dev.txt
