FROM debian:stretch-slim

# OpenSSL with GOST-engine
ARG GOST_ENGINE_VERSION=8bd61488faa22693fa20150fdcb4585e4cf06777
ARG GOST_ENGINE_SHA256="0d1d28daf3a32cd7600f685af818e01c90f92ef878416254973838ab9592422c"
ARG SSL_CONFIG_FILE="/etc/ssl/openssl.cnf"

COPY openssl.cnf ${SSL_CONFIG_FILE}.with-gost

RUN set -xe && apt-get update -yqq && apt-get install --no-install-recommends -yqq \
    libssl-dev \
    build-essential \
    ca-certificates \
    cmake \
    make \
    unzip \
    curl \
    # Build GOST-engine for OpenSSL
    && cd /usr/local/src \
    && curl --http1.1 -fSL "https://github.com/gost-engine/engine/archive/${GOST_ENGINE_VERSION}.zip" -o gost-engine.zip \
    && echo "$GOST_ENGINE_SHA256" gost-engine.zip | sha256sum -c - \
    && unzip gost-engine.zip -d ./ \
    && cd "engine-${GOST_ENGINE_VERSION}" \
    && sed -i 's|printf("GOST engine already loaded\\n");|goto end;|' gost_eng.c \
    && cmake . \
    && make \
    && cd bin \
    && cp gostsum gost12sum /usr/local/bin \
    && cp gost.so.1.1 gost.so /usr/lib/x86_64-linux-gnu/engines-1.1/ \
    && rm -rf "/usr/local/src/gost-engine.zip" "/usr/local/src/engine-${GOST_ENGINE_VERSION}" \
    # Use custom config - enable gost engine
    && cp ${SSL_CONFIG_FILE}.with-gost ${SSL_CONFIG_FILE}

# OpenSSL eo
