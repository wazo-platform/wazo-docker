#!/bin/bash

set -e
set -u  # fail if variable is undefined
set -o pipefail  # fail if command before pipe fails

function wait_for_bootstrap_complete() {
    seconds=0
    timeout=120
    echo -n 'Waiting for bootstrap complete'
    while [ "$seconds" -lt "$timeout" ] && [ "$(docker-compose ps --format json bootstrap | jq --raw-output .[0].State)" != 'exited' ];
      do
        echo -n '.'
        seconds=$((seconds+2))
        sleep 2
      done

    echo ' Ready!'
}

wait_for_bootstrap_complete

echo -n 'Validating bootstrap exit status... '
BOOTSTRAP_EXIT_CODE=$(docker-compose ps --status exited --format json bootstrap | jq --raw-output .[0].ExitCode)
if [ $BOOTSTRAP_EXIT_CODE -ne 0 ]; then
    echo 'FAILED'
    exit 1
fi
echo 'SUCCEED'

echo -n 'Creating token... '
RESULT=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request POST \
  --header 'Content-Type: application/json' \
  --header 'Accept: application/json' \
  --basic \
  --user "root:secret" \
  -d '{}' \
  'https://localhost:8443/api/auth/0.1/token')
TOKEN=$(echo $RESULT | jq --raw-output .data.token)
echo $TOKEN

echo -n 'Validating wazo-auth status... '
AUTH_CODE=$(curl \
  --insecure \
  --silent \
  --show-error \
  --head \
  --output /dev/null \
  --write-out "%{http_code}" \
  'https://localhost:8443/api/auth/0.1/status')

if [ $AUTH_CODE -ne 200 ]; then
  echo 'FAILED'
  exit 1
fi
echo 'SUCCEED'

echo -n 'Validating wazo-provd status... '
PROVD_STATUS=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request GET \
  --header 'Accept: application/vnd.proformatique.provd+json' \
  --header "X-Auth-Token: $TOKEN" \
  'https://localhost:8443/api/provd/0.2/status')

if [ $(echo $PROVD_STATUS | jq --raw-output .rest_api) != 'ok' ]; then
  echo 'FAILED'
  exit 1
fi
echo 'SUCCEED'

echo -n 'Validating wazo-webhookd status... '
WEBHOOKD_STATUS=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request GET \
  --header 'Accept: application/json' \
  --header "X-Auth-Token: $TOKEN" \
  'https://localhost:8443/api/webhookd/1.0/status')

if [ $(echo $WEBHOOKD_STATUS | jq --raw-output .bus_consumer.status) != 'ok' ]; then
  echo 'FAILED (bus_consume)'
  exit 1
fi
if [ $(echo $WEBHOOKD_STATUS | jq --raw-output .master_tenant.status) != 'ok' ]; then
  echo 'FAILED (master_tenant)'
  exit 1
fi
echo "SUCCEED"

echo -n 'Validating wazo-dird status... '
DIRD_STATUS=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request GET \
  --header 'Accept: application/json' \
  --header "X-Auth-Token: $TOKEN" \
  'https://localhost:8443/api/dird/0.1/status')

if [ $(echo $DIRD_STATUS | jq --raw-output .bus_consumer.status) != 'ok' ]; then
  echo 'FAILED (bus_consume)'
  exit 1
fi
if [ $(echo $DIRD_STATUS | jq --raw-output .rest_api.status) != 'ok' ]; then
  echo 'FAILED (rest_api)'
  exit 1
fi
echo "SUCCEED"


echo -n 'Validating wazo-amid status... '
AMID_STATUS=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request POST \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --header "X-Auth-Token: $TOKEN" \
  'https://localhost:8443/api/amid/1.0/action/ping')

if [ $(echo $AMID_STATUS | jq --raw-output .[].Response) != 'Success' ]; then
  echo 'FAILED (ping action)'
  exit 1
fi
echo "SUCCEED"

echo -n 'Validating wazo-calld status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-call-logd status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-chatd status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-phoned status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-setupd status... '
echo 'NOT IMPLEMENTED'

echo -n 'Getting /api/confd/1.1/users... '
USERS=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request GET \
  --header 'Accept: application/json' \
  --header "X-Auth-Token: $TOKEN" \
  'https://localhost:8443/api/confd/1.1/users?recurse=True')
TOTAL_USERS=$(echo $USERS | jq --raw-output .total)
echo "Total: $TOTAL_USERS"
