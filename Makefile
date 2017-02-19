IMAGE_NAME ?= deitch/kubernetes-zookeeper


.PHONY: build



build:
	docker build -t $(IMAGE_NAME) .

