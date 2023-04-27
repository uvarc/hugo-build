FROM alpine:3.11.6
LABEL org.opencontainers.image.source=https://github.com/uvarc/hugo-build

WORKDIR /root/
ENV AWS_DEFAULT_REGION us-east-1

# Update, install Git and things
RUN apk update && apk add py-pip git python2-dev py-yuicompressor coreutils libstdc++ npm && rm -rf /var/cache/apk/*

# Install GLIBC, required for hugo extended version
ENV GLIBC_VERSION 2.30-r0
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
RUN pip install setuptools awscli

# Install html-minifier
RUN npm install -g html-minifier

# Install Hugo 0.59
ADD https://github.com/gohugoio/hugo/releases/download/v0.59.1/hugo_0.59.1_Linux-64bit.tar.gz hugo.tar.gz
RUN tar -xzf hugo.tar.gz && \
    mv hugo /usr/local/bin && \
    rm hugo.tar.gz

# Install Hugo 0.69
ADD https://github.com/gohugoio/hugo/releases/download/v0.69.0/hugo_0.69.0_Linux-64bit.tar.gz hugo-0.69.0.tar.gz
RUN tar -xzf hugo-0.69.0.tar.gz && \
    mv hugo /usr/local/bin/hugo-0.69.0 && \
    rm hugo-0.69.0.tar.gz

# Install Hugo 0.70-extended
ADD https://github.com/gohugoio/hugo/releases/download/v0.70.0/hugo_extended_0.70.0_Linux-64bit.tar.gz hugo-ext-0.70.0.tar.gz
RUN tar -xzf hugo-ext-0.70.0.tar.gz && \
    mv hugo /usr/local/bin/hugo-0.70.0-ext && \
    rm hugo-ext-0.70.0.tar.gz && \
    /usr/local/bin/hugo-0.70.0-ext version

# Install Hugo 0.74-extended
ADD https://github.com/gohugoio/hugo/releases/download/v0.74.0/hugo_extended_0.74.0_Linux-64bit.tar.gz hugo-ext-0.74.0.tar.gz
RUN tar -xzf hugo-ext-0.74.0.tar.gz && \
    mv hugo /usr/local/bin/hugo-0.74.0-ext && \
    rm hugo-ext-0.74.0.tar.gz && \
    /usr/local/bin/hugo-0.74.0-ext version

# Install Hugo 0.80-extended
ADD https://github.com/gohugoio/hugo/releases/download/v0.80.0/hugo_extended_0.80.0_Linux-64bit.tar.gz hugo-ext-0.80.0.tar.gz
RUN tar -xzf hugo-ext-0.80.0.tar.gz && \
    mv hugo /usr/local/bin/hugo-0.80.0-ext && \
    rm hugo-ext-0.80.0.tar.gz && \
    /usr/local/bin/hugo-0.80.0-ext version

# Install Hugo 0.81-extended
ADD https://github.com/gohugoio/hugo/releases/download/v0.81.0/hugo_extended_0.81.0_Linux-64bit.tar.gz hugo-ext-0.81.0.tar.gz
RUN tar -xzf hugo-ext-0.81.0.tar.gz && \
    mv hugo /usr/local/bin/hugo-0.81.0-ext && \
    rm hugo-ext-0.81.0.tar.gz && \
    /usr/local/bin/hugo-0.81.0-ext version

# Install Hugo 0.110-extended 0.110.0+extended
ADD https://github.com/gohugoio/hugo/releases/download/v0.110.0/hugo_extended_0.110.0_Linux-64bit.tar.gz hugo-ext-0.110.0.tar.gz
RUN tar -xzf hugo-ext-0.110.0.tar.gz && \
    mv hugo /usr/local/bin/hugo-0.110.0-ext && \
    rm hugo-ext-0.110.0.tar.gz && \
    /usr/local/bin/hugo-0.110.0-ext version

# Copy in script
COPY build-site.sh /root/build-site.sh
RUN chmod +x /root/build-site.sh
