#!/bin/sh
set -e

# Replace $ENV_API_BASE_URL with the actual environment variable
if [ -n "$API_BASE_URL" ]; then
  echo "Setting API_BASE_URL to $API_BASE_URL"
  sed -i "s|\$ENV_API_BASE_URL|$API_BASE_URL|g" /etc/nginx/conf.d/default.conf
else
  echo "WARNING: API_BASE_URL is not set! Using empty string."
  sed -i "s|\$ENV_API_BASE_URL||g" /etc/nginx/conf.d/default.conf
fi

# Run the original docker-entrypoint.sh with the passed arguments
exec /docker-entrypoint.sh "$@"
