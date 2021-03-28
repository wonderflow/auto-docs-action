# KubeVela Website Sync Action

This action that automatically sync documents from `kubevela` to `kubevela.io`.

## Inputs

### `gh-page`

- [**Required**] - github page repo, must be the ssh address. eg: `git@github.com:sunny0826/pod-lens.github.io.git`

### `docs-path`

- path of docs dir. default: `docs`

## Example usage

```yaml
name: docs
on:
  push:
    paths:
      - 'docs/**'
    branches:
      - master
      - release-*
jobs:
  latest:
    runs-on: ubuntu-latest
    if: ${{ github.ref == 'refs/heads/master' }}
    steps:
      - uses: actions/checkout@v1
      - name: Push to GitHub Repo
        uses: sunny0826/auto-docs-action@v0.2.0
        env:
          SSH_PRIVATE_KEY: ${{ secrets.GH_PAGES_DEPLOY }}
        with:
          gh-page: git@github.com:oam-dev/kubevela.io.git
  released:
    runs-on: ubuntu-latest
    if: ${{ github.ref != 'refs/heads/master' }}
    steps:
      - uses: actions/checkout@v1
      - name: Push to GitHub Repo
        uses: sunny0826/auto-docs-action@v0.2.0
        env:
          SSH_PRIVATE_KEY: ${{ secrets.GH_PAGES_DEPLOY }}
          VERSION: ${{ github.ref }}
        with:
          gh-page: git@github.com:oam-dev/kubevela.io.git
```