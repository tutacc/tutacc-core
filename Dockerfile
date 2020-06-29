############################
# STEP 1 build executable binary
############################
FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git bash wget curl
WORKDIR /go/src/github.com/tutacc/tutacc-core
RUN git clone --progress https://github.com/v2fly/v2ray-core.git . && \
    bash ./release/user-package.sh nosource noconf codename=$(git describe --tags) buildname=tutacc-fly abpathtgz=/tmp/tutacc.tgz
############################
# STEP 2 build a small image
############################
FROM alpine

LABEL maintainer "V2Fly Community <admin@v2fly.org>"
COPY --from=builder /tmp/tutacc.tgz /tmp
RUN apk update && apk add ca-certificates && \
    mkdir -p /usr/bin/tutacc && \
    tar xvfz /tmp/tutacc.tgz -C /usr/bin/tutacc && \
    mv /usr/bin/v2ray /usr/bin/tutacc

#ENTRYPOINT ["/usr/bin/tutacc/tutacc"]
ENV PATH /usr/bin/tutacc:$PATH
CMD ["tutacc", "-config=/etc/tutacc/config.json"]