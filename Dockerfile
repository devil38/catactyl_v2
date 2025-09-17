# ==========================
# Builder stage
# ==========================
FROM ghcr.io/jitesoft/debian:bookworm AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC

# --- Build dependencies ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake g++ make git wget curl tar unzip \
    software-properties-common apt-transport-https ca-certificates \
    locales dos2unix jq libtool-bin autoconf automake \
    zlib1g-dev libbz2-dev libreadline-dev libncurses5-dev libncursesw5-dev \
    libssl3 libcurl4-gnutls-dev libicu-dev libjsoncpp-dev libpng-dev libjpeg-dev \
    libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev \
    libopenal-dev libfreetype6-dev libgmp-dev libzstd-dev libluajit-5.1-dev \
    libirrlicht1.8 libirrlicht-dev libirrlicht-doc libaio1 libncurses5 \
    && dpkg --add-architecture i386 \
    && apt-get update && apt-get install -y --no-install-recommends \
    libtinfo5:i386 libncurses5:i386 libcurl4-gnutls-dev:i386 \
    lib32gcc-s1 lib32tinfo6 lib32z1 lib32stdc++6 libsdl2-2.0-0:i386 \
    libsdl1.2debian libfontconfig1 telnet net-tools netcat iproute2 gdb tzdata \
    && rm -rf /var/lib/apt/lists/*

# --- Timezone & locale ---
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && update-locale LANG=en_US.UTF-8 && dpkg-reconfigure --frontend noninteractive locales

# ==========================
# Runtime stage
# ==========================
FROM ghcr.io/jitesoft/debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    USER=container \
    HOME=/home/container

# --- Essential runtime packages only ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget bash dos2unix tzdata libssl3 libcurl4-gnutls-dev \
    lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 libsdl1.2debian \
    php8.4 php8.4-cli php8.4-common php8.4-fpm php8.4-gd php8.4-mbstring \
    php8.4-bcmath php8.4-xml php8.4-curl php8.4-zip nginx composer \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Create unprivileged user ---
RUN addgroup --gid 998 container \
 && useradd -m -u 999 -d /home/container -g container -s /bin/bash container

WORKDIR /home/container
USER container

# --- Copy only necessary binaries from builder ---
COPY --from=builder /usr/lib /usr/lib
COPY --from=builder /usr/lib32 /usr/lib32
COPY --from=builder /usr/bin/steamcmd /usr/bin/steamcmd

# --- Copy scripts and RCON ---
COPY ./minecraft.sh /minecraft.sh
COPY ./entrypoint.sh /entrypoint.sh
COPY ./rcon /usr/local/bin/rcon

RUN dos2unix /minecraft.sh /entrypoint.sh \
    && chmod +x /minecraft.sh /entrypoint.sh /usr/local/bin/rcon

# --- Entrypoint ---
CMD ["/bin/bash", "/entrypoint.sh"]
