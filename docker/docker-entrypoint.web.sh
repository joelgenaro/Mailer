#!/bin/bash

# Docker web service entrypoint script
# Used for caching gems, so as to not to have to redownload & rebuild them every image build
# See https://medium.com/@cristian_rivera/cache-rails-bundle-w-docker-compose-45512d952c2d

set -e

bundle check || bundle install --binstubs="$BUNDLE_BIN"

exec "$@"
