#!/bin/sh -l

set -e

if [[ -n "$SSH_PRIVATE_KEY" ]]
then
  mkdir -p /root/.ssh
  echo "$SSH_PRIVATE_KEY" > /root/.ssh/id_rsa
  chmod 600 /root/.ssh/id_rsa
fi

mkdir -p ~/.ssh
cp /root/.ssh/* ~/.ssh/ 2> /dev/null || true

echo "git clone"
git config --global user.email "yangsoonlx@gmail.com"
git config --global user.name "kubevela-bot"
git clone --single-branch --depth 1 $1 git-page

echo "sidebars updates"
cat $2/sidebars.js > git-page/sidebars.js

echo "docusaurus.config updates"
cat $2/docusaurus.config.js >  git-page/docusaurus.config.js

echo "index info updates"
cat $2/index.js > git-page/src/pages/index.js

echo "clear en docs"
rm -r git-page/docs/*
echo "clear zh docs"
rm -r git-page/i18n/zh/docusaurus-plugin-content-docs/*
echo "clear resources"
rm -r git-page/resources/*

echo "update resources"
cp -R $2/resources/* git-page/resources/

echo "update docs"
cp -R $2/en/* git-page/docs/
cp -R $2/zh-CN/* git-page/i18n/zh/docusaurus-plugin-content-docs/

echo "git push"
cd git-page

# Check for release only
SUB='release-'
if [[ "$VERSION" == *"$SUB"* ]]
then

  # release-x.y -> vx.y
  version=$(echo $VERSION|sed -e 's/\/*.*\/*-/v/g')
  echo "updating website for version $version"

  if grep -q $version versions.json; then
    rm -r versioned_docs/version-${version}/
    rm versioned_sidebars/version-${version}-sidebars.json
    sed -i.bak "/${version}/d" versions.json
    rm versions.json.bak
  fi

  yarn add nodejieba
  if [ -e yarn.lock ]; then
  yarn install --frozen-lockfile
  elif [ -e package-lock.json ]; then
  npm ci
  else
  npm i
  fi

  yarn run docusaurus docs:version $version
fi

git add .
git commit -m "github action auto sync for $VERSION commit $COMMIT_ID"
git push origin $3