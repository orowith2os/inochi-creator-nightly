#!/usr/bin/env bash

mkdir -p dep.build

# Delete the old working directory
find ./dep.build -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

# Download inochi-creator
pushd dep.build
git clone https://github.com/Inochi2D/inochi-creator.git
popd #dep.build

cat <<EOL > latest-creator.yml
type: git
url: https://github.com/Inochi2D/inochi-creator.git
commit: $(git -C ./dep.build/inochi-creator rev-parse HEAD)
disable-shallow-clone: true
EOL

