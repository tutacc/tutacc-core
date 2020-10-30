FROM --platform=${TARGETPLATFORM} alpine:latest
LABEL maintainer "V2Fly Community <dev@v2fly.org>"

WORKDIR /root
ARG TARGETPLATFORM
COPY v2ray.sh /root/v2ray.sh

RUN set -ex \
	&& apk add --no-cache tzdata openssl ca-certificates \
	&& mkdir -p /etc/v2ray /usr/local/share/v2ray /var/log/v2ray \
	&& chmod +x /root/v2ray.sh \
	&& /root/v2ray.sh "${TARGETPLATFORM}"
RUN mv /etc/v2ray /etc/tutacc
RUN mv /usr/bin/v2ray /usr/bin/tutacc
VOLUME /etc/tutacc
CMD [ "/usr/bin/tutacc", "-config", "/etc/tutacc/config.json" ]
