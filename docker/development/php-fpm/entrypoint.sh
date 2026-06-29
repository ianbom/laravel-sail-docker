#!/bin/sh
set -e

php artisan migrate
mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache

exec "$@"