FROM php:7.3-fpm-alpine

ENV SWOOLE_VERSION=4.5.3
ENV PHP_REDIS=5.3.1
ENV XLSWRITER_VERSION=1.3.6

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

RUN echo "Asia/Shanghai" > /etc/timezone

# update
RUN set -ex \
    && apk update \
    && apk add --no-cache libstdc++ wget openssl bash \
    libmcrypt-dev libzip-dev libpng-dev libc-dev zlib-dev librdkafka-dev \
    freetype freetype-dev libjpeg-turbo libjpeg-turbo-dev libpng libpng-dev \

RUN apk add --no-cache --virtual .build-deps autoconf automake make g++ gcc re2c \
    libtool dpkg-dev dpkg pkgconf file re2c pcre-dev php7-dev php7-pear openssl-dev \

    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/ \ 
    
    # 安装php常用扩展
    && docker-php-ext-install gd bcmath opcache mysqli pdo pdo_mysql sockets zip \

    # Extension redis mcrypt mongodb rdkafka
    && pecl install redis mcrypt mongodb rdkafka \
    && docker-php-ext-enable redis mcrypt mongodb rdkafka \

    # 安装 Composer
    && wget https://mirrors.cloud.tencent.com/composer/composer.phar \
    && mv composer.phar  /usr/local/bin/composer \
    && chmod +x /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/ \

    # 安装 Swoole
    && wget http://pecl.php.net/get/swoole-${SWOOLE_VERSION}.tgz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
        cd swoole \
        && phpize \
        && ./configure --enable-mysqlnd --enable-http2 --enable-openssl \
        && make && make install \
    ) \
    && rm -r swoole \
    && docker-php-ext-enable swoole \

    # 安装 Xlswriter
    && wget http://pecl.php.net/get/xlswriter-${XLSWRITER_VERSION}.tgz -O xlswriter.tar.gz \
    && mkdir -p xlswriter \
    && tar -xf xlswriter.tar.gz -C xlswriter --strip-components=1 \
    && rm xlswriter.tar.gz \
    && cd xlswriter \
    && phpize && ./configure --enable-reader && make && make install \
    && docker-php-ext-enable xlswriter \

    # 删除系统扩展
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* /tmp/* /usr/share/man \
    && php -m

EXPOSE 9500 9501 9502 9503 9504
