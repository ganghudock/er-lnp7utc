#!/bin/bash

stop_requested=false
trap "stop_requested=true" TERM INT

wait_signal() {
    while ! $stop_requested; do
        sleep 1
    done
}

wait_exit() {
    while pidof $1; do
        sleep 1
    done
}

chown -R www-data:www-data /var/www/

if [ ! -s /etc/nginx/koi-win ]; then
    cp -r /etc/nginx-orig/* /etc/nginx/
fi

service nginx restart
service php7.0-fpm restart

wait_signal

echo "Try to exit properly"
service nginx stop
service php7.0-fpm stop

wait_exit "nginx"
