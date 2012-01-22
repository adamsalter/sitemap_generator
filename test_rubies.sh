#!/usr/bin/env bash

# Run the specs across different rubies.
set -o verbose
RBXOPT="-Xrbc.db" rvm ree,1.9.2,1.9.3 exec bundle
RBXOPT="-Xrbc.db" rvm ree,1.9.2,1.9.3 exec bundle exec rake spec
