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

# Install essential tools, libraries, and 32-bit support for Steamcmd
RUN dpkg --add-architecture i386 \
 && apt-get update && apt-get install -y --no-install-recommends \
    curl wget tar unzip dos2unix iputils-ping net-tools netcat telnet tzdata \
    lib32gcc-s1 lib32stdc++6 lib32z1 libtinfo5:i386 libncurses5:i386 \
    libcurl3-gnutls:i386 libtinfo6:i386 libcurl4:i386 libsdl2-2.0-0:i386 \
    libsdl1.2debian libfontconfig1 libpulse0 libgl1-mesa-glx libasound2 \
    libogg-dev libvorbis-dev libopenal-dev libjpeg62-turbo libpng16-16 \
 && rm -f /usr/bin/dd /usr/bin/fallocate /usr/bin/truncate /usr/bin/xfs_mkfile \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy loader scripts and RCON, set permissions
COPY ./minecraft.sh /minecraft.sh
COPY ./rcon /usr/local/bin/rcon
RUN chmod +x /minecraft.sh /usr/local/bin/rcon \
 && dos2unix /minecraft.sh

# Switch to non-root user
USER container
WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
