# wazo-docker

## **WARNING**: Everything in this repo is experimental and not ready for the production

Contains docker-compose file to setup wazo-platform project

## Prerequisite

* Install docker and docker-compose
* Clone the following repositories
    * wazo-platform/wazo-auth-keys
    * wazo-platform/xivo-config
* set environment variable `LOCAL_GIT_REPOS=<path/to/cloned/repositories>`

## Prepare Environment

* `for repo in wazo-auth-keys xivo-config; do git -C "$LOCAL_GIT_REPOS/$repo" pull; done`
* `docker-compose pull --ignore-pull-failures`
  * Note: A lot of images won't be found on registry since they are built locally
* `docker-compose build --pull`

### Use Development Branch Environment
If you want to use a feature in development. You can override docker image from a local folder with
the following steps:

* `cd /<path>/<to>/wazo-<service>/`
* `docker build -t wazoplatform/wazo-<service>:latest .`
* `cd /<path>/<to>/wazo-docker/`
*  `docker compose build <service>`
* `docker compose up -d`

> **Where `<service>` can be**: `asterisk`, `bootstrap`, `chatd`, `confd`, `dird`, `provd`, `webhookd`, `websocketd`, `auth`, `deployd`

## Start Environment

* `docker-compose up --detach`
* Need to accept custom certificate on `https://localhost:8443`
* default username / password: `root` / `secret`

## Clean Environment

* `docker-compose down --volumes`
* `docker-compose up --detach`

## Restart Environment

* `docker-compose down`
* `docker-compose up --detach`

## Test Environment

* Install `curl` and `jq` commands
* `./verify.sh`

## Troubleshooting

* A good starting point for debugging is the `bootstrap` container log
* To get sql prompt: `docker-compose exec postgres psql -U asterisk wazo`
* To use wazo-auth-cli: `docker-compose run --entrypoint bash bootstrap`
* To update only one service without restarting everything

  ```
  docker-compose stop webhookd
  docker-compose rm webhookd
  docker-compose up webhookd
  ```

* **Avoid to use `docker-compose restart <service>`**. It will only restart container without new
  parameters (mount, config, variable)
* When running softphone on the same host than docker, don't use 127.0.0.1:5060, but use *public* IP
  (i.e. 192.168.x.x:5060)
* asterisk configuration are not reload automatically. You must:
  ```bash
  docker-compose exec asterisk bash
  wazo-confgen asterisk/pjsip.conf --invalidate
  asterisk -rx 'core reload'
  ```

## Security

This project has not been developed to be used on production nor exposed on internet
Here is a non-exhaustive list of security concerns that has been found during development

* wazo-phoned expose all unsecured endpoints through nginx
* nginx configuration can be updated on upstream and be desynchronized with this configuration
* Container images embed the `netcat` tool that can be used to open a remote shell.
* Credentials are hardcoded
