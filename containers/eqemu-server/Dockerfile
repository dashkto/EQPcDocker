FROM debian:12-slim AS builder

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y \
    autoconf \
    automake \
    bash \
    build-essential \
    cmake \
    curl \
    git \
    libperl-dev \
    libtool \
    linux-libc-dev \
    ninja-build \
    pkg-config \
    tar \
    unzip \
    uuid-dev \
    zip

ADD Server /source
WORKDIR /source

# Submodules aren't preserved by ADD, so clone them at their pinned commits
RUN git clone https://github.com/microsoft/vcpkg.git submodules/vcpkg && \
    cd submodules/vcpkg && \
    git checkout d1ff36c6520ee43f1a656c03cd6425c2974a449e && \
    ./bootstrap-vcpkg.sh

RUN git clone https://github.com/zaphoyd/websocketpp.git submodules/websocketpp && \
    cd submodules/websocketpp && \
    git checkout b9aeec6eaf3d5610503439b4fae3581d9aff08e8

RUN cmake -S . -B build -G Ninja \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DEQEMU_BUILD_LOGIN=ON \
      -DEQEMU_BUILD_LUA=ON \
      -DEQEMU_BUILD_PERL=ON \
      -DEQEMU_BUILD_CLIENT_FILES=ON && \
    cmake --build build --parallel 1

FROM debian:12-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y \
    bash \
    gettext-base \
    libperl5.36 \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*

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
