FROM alpine:3.11.6
LABEL org.opencontainers.image.source=https://github.com/uvarc/hugo-build

ARG HUGO_VERSION="0.70.0"
ARG HUGO_EXTENDED="true"

LABEL org.opencontainers.image.description="Hugo build container with Hugo version ${HUGO_VERSION} and extended=${HUGO_EXTENDED}"

WORKDIR /root/
ENV AWS_DEFAULT_REGION=us-east-1

# Update, install Git and things
RUN apk update && apk add py-pip git python2-dev py-yuicompressor coreutils libstdc++ wget npm && rm -rf /var/cache/apk/*

# Install GLIBC, required for hugo extended version
ENV GLIBC_VERSION=2.30-r0
RUN apk --no-cache add ca-certificates wget && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk" && \
    apk --no-cache add glibc-${GLIBC_VERSION}.apk && \
    rm "glibc-$GLIBC_VERSION.apk" && \
    wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk" && \
    apk --no-cache add "glibc-bin-$GLIBC_VERSION.apk" && \
    rm "glibc-bin-$GLIBC_VERSION.apk" && \
    wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk" && \
    apk --no-cache add "glibc-i18n-$GLIBC_VERSION.apk" && \
    rm "glibc-i18n-$GLIBC_VERSION.apk"

# Install setuptools
RUN pip3 install setuptools awscli

# Install html-minifier
RUN npm install -g html-minifier

# Install Hugo
RUN if [ "${HUGO_EXTENDED}" = "true" ]; then \
    echo "Installing Hugo Extended version ${HUGO_VERSION}" && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz -O hugo.tar.gz ; \
    else \
    echo "Installing Hugo version ${HUGO_VERSION}" && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -O hugo.tar.gz ; \
    fi && \
    tar -xzf hugo.tar.gz && \
    mv hugo /usr/local/bin && \
    rm hugo.tar.gz

# Copy in script
COPY build-site.sh /root/build-site.sh
RUN chmod +x /root/build-site.sh
