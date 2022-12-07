# PSA Demonstration Steps

This document explains all the steps to successfully run an end to end PSA Demonstration with Docker.

## Preconditions
Please ensure:
- you have Docker Desktop installed 
- you have cloned the git repository using `git clone https://github.com/veraison/services`

## Setup and running of docker containers

Running the below sequence of commands will allow you to setup all 3 services configured using the environment variables defined in `demo.env` file in `veraison/services/deployment/docker`. `demo.env` is used to configure the demo envorinment appropriately.


1. Change directory to the docker deployment directory inside the services repository
```shell
cd services/deployments/docker
```

2. Build the images for the 3 containers
```bash
docker compose --env-file=demo.env build
```

3. Spin up all 3 containers using the images built in the previous step
```bash
docker compose --env-file=demo.env up
```

At this stage you should have all 3 services up and running, shown by the docker output in your terminal.

## Shipping the CORIM

1. Ship the single CORIM that contains the PSA reference values and trust anchor, from the input folder defined by the environment variable `${INPUT_FILE_DIR}` using following command:

```shell
docker exec docker-provisioning-1 bash -c 'cocli corim submit --corim-file="${INPUT_FILE_DIR}"/corim-full.cbor --api-server="http://localhost:8888/endorsement-provisioning/v1/submit" --media-type="application/corim-unsigned+cbor; profile=http://arm.com/psa/iot/1"'
```

In the Docker compose log, it should show the REST frontend returning a success status similiar to what is shown in the logs as follows:

```shell
docker-provisioning-1  | INFO   gin     [GIN] 2022/11/16 - 14:42:52 | 200 |   35.706125ms |       127.0.0.1 | POST     "/endorsement-provisioning/v1/submit"`
```

2. (Optional) You can inspect the KV stores to check what has been generated. The output will print out after running the command

- Verification keys:
```shell
docker exec docker-vts-1 bash -c "sqlite3 ta-store.sql 'select distinct vals from kvstore' | jq ."
```

- Reference values:
```shell
docker exec docker-vts-1 bash -c "sqlite3 en-store.sql 'select distinct vals from kvstore' | jq ."
```


## Exchanging evidence with the Verifier

- Verifying as a Relying Party
```shell
docker exec docker-verification-1 bash -c 'evcli psa verify-as relying-party --api-server=http://localhost:8080/challenge-response/v1/newSession --token="${INPUT_FILE_DIR}"/psa-evidence.cbor'
```

- Verifying as an Attester
```shell
docker exec docker-verification-1 bash -c 'evcli psa verify-as attester --api-server=http://localhost:8080/challenge-response/v1/newSession --claims="${INPUT_FILE_DIR}"/psa-claims-profile-2-integ-without-nonce.json --key="${INPUT_FILE_DIR}"/ec-p256.jwk --nonce-size=32'
```

On verification success, should see 204 and 201 success statuses and the `docker-vts-1` container should log the attestation result with `status:Affirming` to conclude that the result is successful.

NOTE: The value for the environemt variable `${INPUT_FILE_DIR}` is defined inside `default.env` inside the `veraison/services` repository.
