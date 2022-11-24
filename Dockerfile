# Use BuildKit with this file
# deb package will be exported to build directory
# DOCKER_BUILDKIT=1 docker build --output build .
# plain output - usefull for CI\CD
# DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build --output build .

ARG DEBIAN_VERSION=11

FROM debian:${DEBIAN_VERSION} AS fpm

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y --no-install-recommends \
        'build-essential=*' \
        'python3-pip=*' \
        'python3-setuptools=*' \
        'python3-simplejson=*' \
        'git=*' \
        'ruby=*' \
    && apt-get clean \
    && rm -rf /var/lib/apt

# hadolint ignore=DL3028
RUN gem install --no-document fpm

ENTRYPOINT [ "fpm" ]
CMD [ "--help" ]


FROM fpm AS build
ARG DEBIAN_VERSION=11

WORKDIR /tmp/fpm

COPY ./ /tmp/fpm

RUN fpm -s python -t deb \
    --python-bin python3 \
    --python-package-name-prefix python3 \
    --iteration "deb${DEBIAN_VERSION}" \
    --verbose \
    .

FROM scratch AS export

COPY --from=build /tmp/fpm/*.deb /
