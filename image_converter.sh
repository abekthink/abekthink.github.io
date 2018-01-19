#!/usr/bin/env bash

# mac install convert: `brew install imagemagick`

CUR_PATH=`pwd`

IMAGE_PATHS=("/assets/images/robot-framework")

for path in ${IMAGE_PATHS[@]}
do
    path=${CUR_PATH}${path}
    echo "image *.png converted to *.jpg in the path $path"
    cd ${path}
    ls -1 *.png | xargs -n 1 bash -c 'convert -quality 50 "$0" "${0%.png}.jpg"'
done
