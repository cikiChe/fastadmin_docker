#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$1" == apache2* ]] || [ "$1" = 'php-fpm' ]; then
	uid="$(id -u)"
	gid="$(id -g)"
	if [ "$uid" = '0' ]; then
		case "$1" in
			apache2*)
				user="${APACHE_RUN_USER:-www-data}"
				group="${APACHE_RUN_GROUP:-www-data}"

				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
				pound='#'
				user="${user#$pound}"
				group="${group#$pound}"
				;;
			*) # php-fpm
				user='www-data'
				group='www-data'
				;;
		esac
	else
		user="$uid"
		group="$gid"
	fi
fi

## 参考wp写法
if [ ! -e fastadmin/public/index.php ] && [ ! -d fastadmin/addons ]; then

    if [ "$uid" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
        chown "$user:$group" .
    fi

    echo >&2 "fastadmin not found in $PWD - copying now..."
    if [ -n "$(find -mindepth 1 -maxdepth 1 -not -name index.php)" ]; then
        echo >&2 "WARNING: $PWD is not empty! (copying anyhow)"
    fi
    sourceTarArgs=(
        --create
        --file -
        --directory /usr/src/fastadmin
        --owner "$user" --group "$group"
    )
    targetTarArgs=(
        --extract
        --file -
    )
    if [ "$uid" != '0' ]; then
        # avoid "tar: .: Cannot utime: Operation not permitted" and "tar: .: Cannot change mode to rwxr-xr-x: Operation not permitted"
        targetTarArgs+=( --no-overwrite-dir )
    fi
    # loop over "pluggable" content in the source, and if it already exists in the destination, skip it
    # https://github.com/docker-library/wordpress/issues/506 ("wp-content" persisted, "akismet" updated, WordPress container restarted/recreated, "akismet" downgraded)
    # for contentPath in \
    #     # /usr/src/fastadmin/.htaccess \
    #     /usr/src/fastadmin/*/ \
    # ; do
    #     contentPath="${contentPath%/}"
    #     [ -e "$contentPath" ] || continue
    #     contentPath="${contentPath#/usr/src/fastadmin/}" # "wp-content/plugins/akismet", etc.
    #     if [ -e "$PWD/$contentPath" ]; then
    #         echo >&2 "WARNING: '$PWD/$contentPath' exists! (not copying the fastadmin version)"
    #         sourceTarArgs+=( --exclude "./$contentPath" )
    #     fi
    # done
    mkdir -p /var/www/html/fastadmin
    if [ ! -e public/index.php ] && [ ! -d addons ]; then
        cp -rf /usr/src/* /var/www/html/fastadmin/
    fi
    # tar "${sourceTarArgs[@]}" . | tar "${targetTarArgs[@]}"
    echo >&2 "Complete! fastadmin has been successfully copied to $PWD"
fi

# chown -R www-data:www-data /etc/nginx
# chown -R www-data:www-data /var/log/nginx
# chown -R www-data:www-data /run
# chmod -R 777 /run

rm -rf /etc/nginx/sites-enabled/*
#将配置文件放好目录
cp /etc/nginx/web.conf /etc/nginx/sites-enabled/
nginx -t
nginx
rm -rf /etc/nginx/web.conf

## 你知道为什么放这个吗？
exec "$@"