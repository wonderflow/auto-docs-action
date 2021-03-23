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
git config --global user.email "gxd_1105@126.com"
git config --global user.name "maoxian-bot"
git clone --single-branch --depth 1 $1 git-page

echo "sidebars updates"
cat doc/sidebars.js > git-page/sidebars.js

echo "clear en docs"
rm -rf git-page/docs/*
echo "clear zh docs"
rm -rf git-page/i18n/zh/docusaurus-plugin-content-docs/current/*

echo "update docs"
cp -R doc/en/* git-page/docs/
cp -R doc/zh/* git-page/i18n/zh/docusaurus-plugin-content-docs/current/

echo "git push"
cd git-page
if [[ -n "$VERSION" ]]
then
  yarn add nodejieba
  if [ -e yarn.lock ]; then
  yarn install --frozen-lockfile
  elif [ -e package-lock.json ]; then
  npm ci
  else
  npm i
  fi
  # release-0.0.1 -> v0.0.1
  version=$(echo $VERSION|sed -e 's/\/*.*\/*-/v/g')
  echo "version $version"
  yarn run docusaurus docs:version $version
fi
git add .
git commit -m "github action auto sync"
git push origin master