#!/bin/bash

#Download fly 
curl 'http://localhost:8080/api/v1/cli?arch=amd64&platform=linux' -o fly && chmod +x ./fly && sudo mv ./fly /usr/local/bin/

git branch | cut -c 3- >curr_branches.txt

Fgrep -v -f present_pipeline_branches.txt curr_branches.txt >no_pipeline_branches.txt

export new_version=$(cat no_pipeline_branches.txt)

fly -t tutorial login -c http://localhost:8080 -u test -p test 

for version in $new_version; do
  sed "s/___BRANCH___/$version/g" demo/.ci/pipeline-demo.tmpl > demo/.ci/pipeline-app.result
  echo "Create pipeline branch $version"
  fly -t tutorial sp -p app-$version -c demo/.ci/pipeline-app.result
  echo "Unpause pipeline branch $version"
  fly -t tutorial up -p app-$version
  echo “$version” >> present_pipeline_branches.txt
done

Fgrep -v -f curr_branches.txt present_pipeline_branches.txt >deleted_branches.txt

export old_version=$(cat branches/deleted_branched.txt)

for version in $OLD_VERSIONS; do
  echo "Delete pipeline branch $version"
  fly -t tutorial dp -p app-$version
done

Fgrep -v -f present_pipeline_branches.txt deleted_branches.txt >present_pipeline_branches.txt
