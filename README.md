# wazo-docker

## **WARNING**: Everything in this repo is experimental and not ready for the production

Contains docker-compose file to setup wazo-platform project

## Prerequisite

* Install docker and docker-compose
* Clone the following repositories
    * wazo-platform/wazo-auth
    * wazo-platform/wazo-auth-keys
    * wazo-platform/wazo-sysconfd
    * wazo-platform/xivo-manage-db
* set environment variable `LOCAL_GIT_REPOS=<path/to/cloned/repositories>`

## Prepare Environment

* `docker-compose pull`
* `docker-compose build --pull`

## Start Environment

* `docker-compose up -d`
* Need to accept custom certificate on `https://localhost:8443`
* default username / password: `root` / `secret`

## Restart Environment

* `docker-compose down -v`
* `docker-compose up -d`
