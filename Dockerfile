FROM debian:buster AS deb_sysd

# Install systemd
RUN apt-get update \
    && apt-get install -y systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -f /lib/systemd/system/multi-user.target.wants/* \
    /etc/systemd/system/*.wants/* \
    /lib/systemd/system/local-fs.target.wants/* \
    /lib/systemd/system/sockets.target.wants/*udev* \
    /lib/systemd/system/sockets.target.wants/*initctl* \
    /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
    /lib/systemd/system/systemd-update-utmp*

VOLUME [ "/sys/fs/cgroup" ]

CMD ["/lib/systemd/systemd"]

FROM deb_sysd

# Install dependencies
RUN apt-get update \
	&& apt-get -y install sudo lsb-release apt-transport-https ca-certificates wget unzip curl \
	&& wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
	&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
	&& apt-get update \
	&& apt-get install -y apache2 mariadb-server php7.4 libapache2-mod-php7.4 php7.4-bz2 php7.4-gd php7.4-mbstring php7.4-mysql php7.4-zip php7.4-xdebug php7.4-gettext php7.4-cli php7.4-xml php7.4-curl autoconf libtool git build-essential cmake libmariadb-dev \
	&& apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add onh user with password "onh"
RUN useradd -m -p HGX6qp3QXlEio -s /bin/bash onh \
	&& usermod -a -G sudo onh

WORKDIR /home/onh/

# Install libmodbus
RUN mkdir modbus && cd modbus \
	&& git clone https://github.com/stephane/libmodbus/ \
	&& cd libmodbus \
	&& ./autogen.sh && ./configure --prefix=/usr && make && make install

# Install googletest
RUN mkdir gtest && cd gtest \
	&& git clone https://github.com/google/googletest/ \
	&& cd googletest \
	&& mkdir build && cd build \
	&& cmake .. && make && make install

# Install composer
RUN mkdir composer && cd composer \
	&& curl -sS https://getcomposer.org/installer -o composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer
