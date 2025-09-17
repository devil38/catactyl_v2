FROM ghcr.io/jitesoft/debian:bullseye

LABEL author="Devil38" maintainer="itznya10@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends install apt-utils curl software-properties-common apt-transport-https ca-certificates wget tar dirmngr gnupg iproute2 make g++ locales git cmake zip unzip libtool-bin autoconf automake jq rpl locales
    
## User 
RUN addgroup --gid 998 container \
 && useradd -m -u 999 -d /home/container -g container -s /bin/bash container
  
    # Timezone
ENV TZ=UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

  # Font 
RUN update-locale lang=en_US.UTF-8 \
 && dpkg-reconfigure --frontend noninteractive locales

   # Fixes
RUN apt-get install -y --no-install-recommends gcc libcairo2-dev libpango1.0-dev libgcc1 gdb libc6 binutils xz-utils liblzo2-2 net-tools netcat telnet libatomic1 libsdl1.2debian libsdl2-2.0-0 libicu-dev icu-devtools libunwind8 libmariadb-dev-compat openssl libc6-dev libstdc++6 libssl1.1 libcurl4-gnutls-dev libjsoncpp-dev python3 build-essential zlib1g-dev libbz2-dev libreadline-dev libncurses5-dev libncursesw5-dev tk-dev libffi-dev libssl-dev less libasound2 libglib2.0-0 libnss3 libpulse0 libxslt1.1 libxkbcommon0 python libyaml-0-2 libpython2.7

  # Font 
RUN update-locale lang=en_US.UTF-8 \
 && dpkg-reconfigure --frontend noninteractive locales  

  # Others
RUN apt-get update && apt-get install -y --no-install-recommends libxkbfile-dev libsecret-1-dev toilet libncursesw5 re2c bison file

  # Cleanup
RUN apt-get autoremove -y

  # hmmmmmm
RUN rm -rf /usr/bin/dd \
 && rm -rf /usr/bin/fallocate \
 && rm -rf /usr/bin/truncate \
 && rm -rf /usr/bin/xfs_mkfile 

  # loader
COPY ./minecraft.sh /minecraft.sh
RUN apt-get update \
 && apt-get install -y --no-install-recommends dos2unix iputils-ping \
 && dos2unix /minecraft.sh \
 && chmod +x /minecraft.sh

# MariaDB
RUN apt-get update \
  && apt-get install -y libncurses5 libaio1
 
# Minetest
RUN apt-get update \
  && apt-get install -y g++ make libc6-dev cmake libpng-dev libjpeg-dev libxxf86vm-dev libgl1-mesa-dev libsqlite3-dev libogg-dev libvorbis-dev libopenal-dev libcurl4-gnutls-dev libfreetype6-dev zlib1g-dev libgmp-dev libjsoncpp-dev libzstd-dev libluajit-5.1-dev libirrlicht1.8 libirrlicht-dev libirrlicht-doc
  
   # Steamcmd additional libs
RUN dpkg --add-architecture i386 \
  && apt-get update \
  && apt-get install -y libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 \
  && apt-get install -y tar curl gcc g++ lib32gcc-s1 libgcc1 libcurl4-gnutls-dev:i386 libssl1.1:i386 libcurl4:i386 lib32tinfo6 libtinfo6:i386 lib32z1 lib32stdc++6 libncurses5:i386 libcurl3-gnutls:i386 libsdl2-2.0-0:i386 iproute2 gdb libsdl1.2debian libfontconfig1 telnet net-tools netcat tzdata
  
  # install rcon
RUN curl -sSL https://pterodactyl-api.catactyl.xyz/env_x86/rcon > /usr/local/bin/rcon \
  && chmod +x /usr/local/bin/rcon

  # PHP & Nginx & Composer & Caddy
RUN apt-get update -y \
  && apt-get install -y lsb-release \
  && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list \
  && curl -fsSL  https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg \
  && apt-get update \
  && apt-get install -y php8.1 php8.1-common php8.1-cli php8.1-gd php8.1-mysql php8.1-mbstring php8.1-bcmath php8.1-xml php8.1-fpm php8.1-curl php8.1-zip \
  && apt-get install -y nginx \
  && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

  # install some stuff
RUN apt-get update -y \
  && apt-get install -y xdg-user-dirs

USER container
ENV  USER container
ENV  HOME /home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh

CMD ["/bin/bash", "/entrypoint.sh"]
