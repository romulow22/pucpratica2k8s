#!/bin/sh
envsubst '${REACT_APP_BACKEND_URL}' < /etc/nginx/nginx.template > /etc/nginx/nginx.conf
nginx -g 'daemon off;'