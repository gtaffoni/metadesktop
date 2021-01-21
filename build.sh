#!/bin/bash

if [ 'xxx${VERSION}' == 'xxx' ]; then
   VERSION='latest'
fi

docker build -t morgan1971/metadesktop:${VERSION} .

