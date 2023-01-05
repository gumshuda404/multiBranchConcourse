#!/bin/bash

export NEW_VERSIONS=$(cat branches/branches)
export OLD_VERSIONS=$(cat branches/removed)

fly -t tutorial login -c http://localhost:8080 -u test -p test 

for version in $NEW_VERSIONS; do
  sed "s/___BRANCH___/$version/g" demo/.ci/pipeline-demo.tmpl > demo/.ci/pipeline-app.result
  echo "Create pipeline branch $version"
  fly -t tutorial sp -p app-$version -c demo/.ci/pipeline-app.result
  echo "Unpause pipeline branch $version"
  fly -t tutorial up -p app-$version
done

for version in $OLD_VERSIONS; do
  echo "Delete pipeline branch $version"
  fly -t tutorial dp -p app-$version
done
