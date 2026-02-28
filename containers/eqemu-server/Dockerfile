FROM debian:12-slim AS builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y \
    bash \
    build-essential \
    cmake \
    cpp \
    debconf-utils \
    g++ \
    gcc \
    git \
    libboost-dev \
    libcurl4-openssl-dev \
    liblua5.1-dev \
    libluajit-5.1-dev \
    libmariadb-dev \
    libsodium-dev \
    libssl-dev \
    libuv1-dev \
    lua5.1 \
    lua-bitop \
    make \
    mariadb-client \
    pkg-config \
    uuid-dev

ADD Server /source
WORKDIR /source

RUN mkdir -p build && \
    cd build && \
    cmake -G 'Unix Makefiles' -DEQEMU_BUILD_LOGIN=ON .. && \
    make -j $(nproc)

FROM debian:12-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y \
    bash \
    gdb \
    gettext-base \
    git \
    liblua5.1-0 \
    libluajit-5.1-2 \
    libuv1 \
    lua5.1 \
    lua-bitop \
    mariadb-client \
    nano

RUN mkdir -p /app/logs
RUN mkdir -p /app/shared

WORKDIR /app

COPY --from=ghcr.io/ufoscout/docker-compose-wait:latest /wait /wait
COPY --from=builder /source/build/bin /app

ADD Server/loginserver/login_util/*.conf /app/
ADD Server/utils/patches/*.conf /app/

ADD Maps /app/Maps
ADD Quests /app/quests

ADD containers/eqemu-server/login.template.json /app/
ADD containers/eqemu-server/eqemu_config.template.json /app/

ADD containers/eqemu-server/docker-entrypoint.sh /docker-entrypoint.sh

ENTRYPOINT [ "/docker-entrypoint.sh" ]
