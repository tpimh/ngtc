FROM alpine:latest

RUN apk add --no-cache -t .llvmdeps \
	clang-dev \
	clang-static \
	cmake \
	g++ \
	git \
	libexecinfo-dev \
	linux-headers \
	make \
	ninja \
	patch \
	python
