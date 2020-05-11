FROM debian:latest AS deb_sysd

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
	&& apt-get install -y sudo autoconf libtool git build-essential cmake apache2 mariadb-server libmariadb-dev php libapache2-mod-php php-mysql php-xdebug php-mbstring php-gettext php-cli unzip curl \
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
	&& ./autogen.sh && ./configure --prefix=/usr && make && make install && ln -s /usr/include/modbus/ /usr/local/include/modbus

# Install googletest
RUN mkdir gtest && cd gtest \
	&& git clone https://github.com/google/googletest/ \
	&& cd googletest \
	&& cmake CMakeLists.txt && make && make install

# Install composer
RUN mkdir composer && cd composer \
	&& curl -sS https://getcomposer.org/installer -o composer-setup.php \
	&& php composer-setup.php --install-dir=/usr/local/bin --filename=composer
