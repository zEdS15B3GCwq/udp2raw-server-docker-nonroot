#
# Dockerfile for udp2raw
# based on Dockerfile for phantun @ https://github.com/dndx/phantun/pull/92/files
#

#
# Build stage
#
FROM alpine:latest AS builder

#COPY . /phantun

RUN apk update \
  && apk add --no-cache --virtual .build-deps git make linux-headers g++ \
  && cd / \
  && git clone https://github.com/wangyu-/udp2raw.git udp2raw \
  && cd /udp2raw \
  && make \
  && mv ./udp2raw /usr/local/bin/ \
  && cd / \
  && rm -r udp2raw \
  && apk del .build-deps \
  && rm -rf /var/cache/apk/*

#
# Runtime stage
#
FROM alpine:latest

COPY --from=builder /usr/local/bin/udp2raw /usr/local/bin/

RUN apk update \
  && apk add --no-cache iptables libcap su-exec \
  && setcap cap_net_raw=+pe /usr/local/bin/udp2raw \
  && apk del libcap \
  && rm -rf /var/cache/apk/*

COPY init.sh /usr/local/bin/

ENTRYPOINT ["init.sh"]
CMD ["whoami"]
