# wazo-docker

## **WARNING**: Everything in this repo is experimental and not ready for the production

Contains docker-compose file to setup wazo-platform project

## Prerequisite

* Install docker and docker-compose
* Clone the following repositories
    * wazo-platform/wazo-auth-keys
    * wazo-platform/wazo-dird
    * wazo-platform/wazo-webhookd
    * wazo-platform/xivo-config
    * wazo-platform/xivo-manage-db
* set environment variable `LOCAL_GIT_REPOS=<path/to/cloned/repositories>`

## Prepare Environment

* `for repo in wazo-auth-keys wazo-dird wazo-webhookd xivo-config xivo-manage-db; do git -C "$LOCAL_GIT_REPOS/$repo" pull; done`
* `docker-compose pull --ignore-pull-failures`
* `docker-compose build --pull`

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
