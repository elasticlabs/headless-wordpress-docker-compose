#!/bin/sh

# Installs all packages if required by Make
if [ "$1" == "install" ]; then
  npm install
else
  exec "$@"
fi