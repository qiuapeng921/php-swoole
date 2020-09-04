### `php-swoole`

- 基于官方 `php:7.3-fpm-alpine` 镜像构建的 `php-swoole` 镜像,可用于`fpm`或`cli`

- 内置工具:
```
composer curl wget vim
```

### 已装扩展

```
bcmath
Core
ctype
curl
date
dom
fileinfo
filter
ftp
gd
hash
iconv
json
libxml
mbstring
mcrypt
mongodb
mysqli
mysqlnd
openssl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
rdkafka
readline
redis
Reflection
session
SimpleXML
sockets
sodium
SPL
sqlite3
standard
swoole
tokenizer
xml
xmlreader
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```

### 使用方式

docker-compose.yml 配置
```
version: '3'
php73:
    image: qiuapeng921/php-swoole:stable
    ports:
      - "9500:9500"
      - "9501:9501"
      - "9502:9502"
      - "9503:9503"
      - "9504:9504"
    tty: true # 如果不启动服务，需要打开这个让镜像启动
    volumes:
      - ${APP_DIR}:/var/www/html/:rw
      - ${PHP73_PHP_CONF_FILE}:/usr/local/etc/php/php.ini:ro
      - ${PHP73_FPM_CONF_FILE}:/usr/local/etc/php-fpm.d/www.conf:rw
    restart: always
    cap_add:
      - SYS_PTRACE
```

```
APP_DIR 项目根目录
PHP73_PHP_CONF_FILE php.ini配置
PHP73_FPM_CONF_FILE www.conf配置
```