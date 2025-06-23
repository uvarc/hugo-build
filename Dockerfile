FROM alpine:3.11.6
LABEL org.opencontainers.image.source=https://github.com/uvarc/hugo-build

ARG HUGO_VERSION="0.59.0"

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
RUN wget https://github.com/gohugoio/hugo/releases/download/v$(echo ${HUGO_VERSION} | sed 's/[^.0-9]//g')/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -O hugo.tar.gz && \
    tar -xzf hugo.tar.gz && \
    mv hugo /usr/local/bin && \
    rm hugo.tar.gz

# Copy in script
COPY build-site.sh /root/build-site.sh
RUN chmod +x /root/build-site.sh
