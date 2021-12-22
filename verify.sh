#!/bin/bash

set -e
set -u  # fail if variable is undefined
set -o pipefail  # fail if command before pipe fails

echo 'Verify consul'
docker-compose exec -T 'consul_server consul catalog services | grep rabbitmq'

function wait_for_bootstrap_complete() {
    seconds=0
    timeout=120
    echo -n 'Waiting for bootstrap complete'
    while [ "$seconds" -lt "$timeout" ] && ! docker-compose ps bootstrap | grep "Exit 0" > /dev/null
      do
        echo -n '.'
        seconds=$((seconds+2))
        sleep 2
      done
    echo ' Ready!'
}

wait_for_bootstrap_complete

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
PROVD_STATUS=$(curl \
  --insecure \
  --silent \
  --show-error \
  --request GET \
  --header 'Accept: application/json' \
  --header "X-Auth-Token: $TOKEN" \
  'https://localhost:8443/api/webhookd/1.0/status')

if [ $(echo $PROVD_STATUS | jq --raw-output .bus_consumer.status) != 'ok' ]; then
  echo 'FAILED (bus_consume)'
  exit 1
fi
if [ $(echo $PROVD_STATUS | jq --raw-output .master_tenant.status) != 'ok' ]; then
  echo 'FAILED (master_tenant)'
  exit 1
fi
echo "SUCCEED"

echo -n 'Validating wazo-calld status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-call-logd status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-chatd status... '
echo 'NOT IMPLEMENTED'

echo -n 'Validating wazo-dird status... '
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
