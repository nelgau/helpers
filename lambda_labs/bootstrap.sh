#!/bin/sh
set -euxo pipefail

git config --global user.name "Nelson Gauthier"
git config --global user.email "nelson.gauthier@gmail.com"

ssh-keyscan github.com >> ~/.ssh/known_hosts

rm -rf helpers
git clone git@github.com:nelgau/helpers.git

sudo helpers/lambda_labs/user-create.sh
