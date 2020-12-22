#!/bin/sh
set -euo pipefail

if [ ! -d nextjs-material-kit ]; then 
  git clone https://github.com/creativetimofficial/nextjs-material-kit.git
  # Create destination directory and install packages
  npm install
fi