NAME = akisys/hadoop
VERSION = 2.8.0

.PHONY: all build run

all: build

build:
	docker build -t $(NAME):$(VERSION) --rm .

run:
	docker run -it $(NAME):$(VERSION) /bin/bash
