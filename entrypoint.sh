#!/bin/sh -l

set -e

echo "git clone"
git config --global user.email "actions@github.com"
git config --global user.name "gh-actions"
git clone --single-branch --depth 1 $1 git-page

echo "clear en docs"
rm -rf git-page/docs/*
echo "clear zh docs"
rm -rf git-page/i18n/zh/docusaurus-plugin-content-docs/current/*

echo "update docs"
cp -R doc/en/* git-page/docs/
cp -R doc/zh/* git-page/i18n/zh/docusaurus-plugin-content-docs/current/

echo "git push"
cd git-page
git add .
git commit -m "github action auto sync"
git push origin master