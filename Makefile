IMAGE_NAME ?= deitch/kubernetes-zookeeper:3.4.9


.PHONY: build



build:
	docker build -t $(IMAGE_NAME) .

push:
	docker push $(IMAGE_NAME)

