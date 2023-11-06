FROM php:7.4-fpm 
LABEL maintainer="466934322@qq.com"

# RUN sed -i 's/http:\/\/deb.debian.org\/debian/http:\/\/mirrors.tuna.tsinghua.edu.cn\/debian/g' /etc/apt/sources.list

# persistent dependencies
RUN set -eux; \
  sed -i 's/http:\/\/deb.debian.org\/debian/http:\/\/mirrors.tuna.tsinghua.edu.cn\/debian/g' /etc/apt/sources.list; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
# Ghostscript is required for rendering PDF previews
		ghostscript \
    zip \
    unzip \
    nginx \
	; \
	rm -rf /var/lib/apt/lists/*

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	\
	apt-get update; \
	apt-get install -y --no-install-recommends \
		libfreetype6-dev \
		libicu-dev \
		libjpeg-dev \
		libmagickwand-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \
	; \
	\
  pecl install redis; \
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	; \
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		intl \
		mysqli \
		zip \
		pdo_mysql \
		fileinfo \
	; \
  docker-php-ext-enable redis;



RUN set -eux; \
	#version='6.3'; \
	#sha1='5ae2e02020004f7a848fc4015d309a0479f7c261'; \
	\
	curl -o fastadmin.zip -fL "https://www.fastadmin.net/download/full.html"; \
	#echo "$sha1 *fastadmin.zip" | sha1sum -c -; \
	\
# upstream tarballs include ./fastadmin/ so this gives us /usr/src/fastadmin
	# unzip -xzf fastadmin.zip -C /usr/src/; \
	unzip -o fastadmin.zip -d /usr/src/; \
	rm -f  fastadmin.zip; 

VOLUME /var/www/html
VOLUME /etc/nginx/sites-enabled/
workdir /var/www/html

COPY docker-entrypoint.sh /usr/local/bin/
COPY web.conf /etc/nginx
EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]