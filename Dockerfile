FROM ghcr.io/jitesoft/debian:bookworm

LABEL author="Devil38" maintainer="itznya10@gmail.com"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    USER=container \
    HOME=/home/container

# Set timezone and locale
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y --no-install-recommends locales \
    && dpkg-reconfigure --frontend noninteractive locales

# Create user and group
RUN addgroup --gid 998 container \
 && useradd -m -u 999 -d $HOME -g container -s /bin/bash container

# Base utilities & development tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils curl software-properties-common apt-transport-https ca-certificates \
    wget tar dirmngr gnupg iproute2 make g++ locales git cmake zip unzip \
    libtool-bin autoconf automake jq rpl dos2unix iputils-ping \
    gcc libcairo2-dev libpango1.0-dev libgcc1 gdb libc6 binutils xz-utils \
    liblzo2-2 net-tools telnet libatomic1 libsdl1.2debian libsdl2-2.0-0 \
    libicu-dev icu-devtools libunwind8 libmariadb-dev-compat openssl \
    libc6-dev libstdc++6 libssl-dev libcurl4-gnutls-dev libjsoncpp-dev \
    python3 python3-pip build-essential zlib1g-dev libbz2-dev libreadline-dev \
    libncurses5-dev libncursesw5-dev tk-dev libffi-dev less libasound2 \
    libglib2.0-0 libnss3 libpulse0 libxslt1.1 libyaml-0-2 \
    libxkbfile-dev libsecret-1-dev toilet re2c bison file libaio1 \
    libpng-dev libjpeg-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev \
    libogg-dev libvorbis-dev libopenal-dev libfreetype6-dev libgmp-dev \
    libzstd-dev libluajit-5.1-dev libirrlicht1.8 libirrlicht-dev libirrlicht-doc \
    g++ make libc6-dev cmake xdg-user-dirs \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# i386 libraries for Steamcmd
RUN dpkg --add-architecture i386 \
 && apt-get update && apt-get install -y --no-install-recommends \
    libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 \
    lib32gcc-s1 lib32stdc++6 lib32z1 libtinfo6:i386 libcurl4:i386 \
    libsdl2-2.0-0:i386 iproute2 gdb libsdl1.2debian libfontconfig1 \
    tzdata && apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove dangerous binaries
RUN rm -f /usr/bin/dd /usr/bin/fallocate /usr/bin/truncate /usr/bin/xfs_mkfile

# Loader script
COPY ./minecraft.sh /minecraft.sh
RUN chmod +x /minecraft.sh \
 && dos2unix /minecraft.sh

# Install RCON from local file
COPY ./rcon /usr/local/bin/rcon
RUN chmod +x /usr/local/bin/rcon

# Switch to non-root user
USER container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
