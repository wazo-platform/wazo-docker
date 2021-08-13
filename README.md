# wazo-docker

## **WARNING**: Everything in this repo is experimental and not ready for the production

Contains docker-compose file to setup wazo-platform project

## Prerequisite

* Install docker and docker-compose
* Clone the following repositories
    * wazo-platform/wazo-asterisk-config
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

## Troubleshooting

* To get sql prompt: `docker-compose exec postgres psql -U asterisk wazo`
* To use wazo-auth-cli: `docker-compose run --entrypoint bash bootstrap`
* To update only one service without restarting everything

  ```
  docker-compose stop webhookd
  docker-compose rm webhookd
  docker-compose up webhookd
  ```

* **Avoid to user `docker-compose restart <service>`**. It will only restart container without new
  parameters (mount, config, variable)
