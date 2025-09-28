FROM ghcr.io/jitesoft/debian:trixie-slim

LABEL author="Devil38" maintainer="itznya10@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC


# Base system & essentials
RUN apt-get update && apt-get -y --no-install-recommends install \
    apt-utils curl wget tar ca-certificates gnupg dirmngr iproute2 \
    apt-transport-https locales git \
    make g++ cmake zip unzip autoconf automake libtool-bin jq rpl \
    && rm -rf /var/lib/apt/lists/*

# User
RUN addgroup --gid 998 container \
 && useradd -m -u 999 -d /home/container -g container -s /bin/bash container

# Timezone & locale
RUN apt-get update && apt-get install -y --no-install-recommends locales \
 && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
 && locale-gen \
 && update-locale LANG=en_US.UTF-8 \
 && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
 && echo $TZ > /etc/timezone \
 && rm -rf /var/lib/apt/lists/*
 
# Core build and runtime deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc gdb libc6-dev libstdc++6 libssl3 libssl-dev \
    libcairo2-dev libpango1.0-dev libicu-dev icu-devtools \
    libunwind8 libmariadb-dev-compat zlib1g-dev libbz2-dev \
    libreadline-dev libncurses5-dev libncursesw5-dev tk-dev \
    libffi-dev python3 python3-pip python3-dev build-essential \
    libasound2 libglib2.0-0 libnss3 libpulse0 libxslt1.1 \
    libxkbcommon0 libyaml-0-2 \
    && rm -rf /var/lib/apt/lists/*

# Extra tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxkbfile-dev libsecret-1-dev toilet re2c bison file less \
    && rm -rf /var/lib/apt/lists/*

# Dangerous binaries cleanup
RUN rm -f /usr/bin/dd /usr/bin/fallocate /usr/bin/truncate /usr/bin/xfs_mkfile

# Loader
COPY ./minecraft.sh /minecraft.sh
RUN apt-get update \
 && apt-get install -y --no-install-recommends dos2unix iputils-ping \
 && dos2unix /minecraft.sh \
 && chmod +x /minecraft.sh \
 && rm -rf /var/lib/apt/lists/*

# Minetest build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ make libc6-dev cmake libpng-dev libjpeg-dev libxxf86vm-dev \
    libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev \
    libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev \
    libgmp-dev libjsoncpp-dev libzstd-dev libluajit-5.1-dev \
    libirrlicht-dev libirrlicht-doc \
    && rm -rf /var/lib/apt/lists/*

# SteamCMD libs (i386 support)
RUN dpkg --add-architecture i386 \
 && apt-get update && apt-get install -y --no-install-recommends \
    libtinfo6:i386 libncurses6:i386 libcurl4-gnutls-dev:i386 \
    lib32gcc-s1 lib32stdc++6 lib32z1 \
    libsdl2-2.0-0:i386 libssl3:i386 \
    tar curl gcc g++ gdb iproute2 netcat-traditional telnet net-tools \
    libfontconfig1 tzdata \
 && rm -rf /var/lib/apt/lists/*

# Other stuff
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    xdg-user-dirs \
 && rm -rf /var/lib/apt/lists/*
 
# RCON
# Copy loader scripts and RCON, set permissions
COPY ./minecraft.sh /minecraft.sh
COPY ./rcon /usr/local/bin/rcon
RUN chmod +x /minecraft.sh /usr/local/bin/rcon \
 && dos2unix /minecraft.sh

USER container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
