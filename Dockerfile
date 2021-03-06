FROM alpine:3.5

MAINTAINER diego@passbolt.com

ENV PASSBOLT_VERSION 1.5.1
ENV PASSBOLT_URL https://github.com/passbolt/passbolt_api/archive/v${PASSBOLT_VERSION}.tar.gz

ARG BASE_PHP_DEPS="php5-curl \
      php5-common \
      php5-gd \
      php5-intl \
      php5-json \
      php5-mcrypt \
      php5-memcache \
      php5-mysql \
      php5-xsl \
      php5-fpm \
      php5-phar \
      php5-xml \
      php5-openssl \
      php5-zlib \
      php5-ctype \
      php5-pdo \
      php5-pdo_mysql \
      php5-pear"

ARG PHP_GNUPG_DEPS="php5-dev \
      make \
      gcc \
      g++ \
      libc-dev \
      pkgconfig \
      re2c \
      gpgme-dev \
      autoconf \
      file"

RUN apk update &&\
    apk add $BASE_PHP_DEPS \
      bash \
      ca-certificates \
      curl \
      tar \
      libpcre32 \
      recode \
      libxml2 \
      gpgme \
      gnupg1 \
      mysql-client \
      openssl \
      nginx

RUN apk add $PHP_GNUPG_DEPS && \
    #https://bugs.alpinelinux.org/issues/5378
    sed -i "s/ -n / /" $(which pecl) && \
    pecl install gnupg && \
    echo "extension=gnupg.so" > /etc/php5/conf.d/gnupg.ini && \
    apk del $PHP_GNUPG_DEPS

RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

RUN mkdir /var/www/passbolt && curl -sSL $PASSBOLT_URL | \
      tar zxf - -C /var/www/passbolt --strip-components 1 && \
    chown -R nginx:nginx /var/www/passbolt && \
    chmod -R +w /var/www/passbolt/app/tmp && \
    chmod +w /var/www/passbolt/app/webroot/img/public

COPY conf/passbolt.conf /etc/nginx/conf.d/default.conf
COPY bin/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 80 443

CMD ["/docker-entrypoint.sh"]
