# PSA Demonstration Steps

This document explains all the steps one need to follow to successfully run
end to end PSA Demonstration

## Preconditions

* One need to install `jq` and `curl`.

## Provisioning pipeline setup

* Install `cocli tool` using following command

In a new bourne shell session

```shell
go install github.com/veraison/corim/cocli@demo-psa-1.0.0
```

* For provisioning if Supply Chain Endorsements needs to be modified or created fresh, then one needs to use instructions given [here](./COCLI_README.md)

To run provisioning test you need three parallel bourne shell sessions.

In each shell, move to the folder where you are going to clone the GIT repo and do:

```shell
export TOPDIR=$(pwd)
```

### Steps

In the first shell, clone the Veraison services repository:

```shell
git clone https://github.com/veraison/services
```

Build the services:

```shell
make -C ${TOPDIR}/services
```

Start the REST API frontend:

```shell
( cd ${TOPDIR}/services/provisioning/cmd && ./provisioning-service )
```

In another shell create the KV stores:

```shell
( cd ${TOPDIR}/services/cmd/vts/cmd && ../test-harness/init-kvstores.sh )
````

Then start the VTS service:

```shell
( cd ${TOPDIR}/services/cmd/vts && ./vts-service )
```

In the third shell

```shell
git clone https://github.com/veraison/docs
```

Move to the docs/demo/psa/prov-verif-e2e folder:

```shell
cd ${TOPDIR}/docs/demo/psa/prov-verif-e2e
```

Ship the single CORIM that contains PSA reference values and trust anchor from data/cbor folder using following command

```shell
cocli corim submit --corim-file=data/cbor/corim-full.cbor --api-server="http://localhost:8888/endorsement-provisioning/v1/submit" --media-type="application/corim-unsigned+cbor; profile=http://arm.com/psa/iot/1"
```

The REST frontend should return a success status.

If so, you can inspect the KV stores to check what has been generated:

* Verification keys:

```shell
sqlite3 ${TOPDIR}/services/vts/cmd/ta-store.sql 'select distinct vals from kvstore' | jq .
```

* Reference values:

```shell
sqlite3 ${TOPDIR}/services/vts/cmd/en-store.sql 'select distinct vals from kvstore' | jq .
```

### Cleanup

Use Ctrl-C to stop the REST provisioning frontend in shells 1 (as one 
would not need provisioning service once the Reference Values and
Endorsements are now provisioned into Verification service)

## Verification pipeline setup

If not already done, ensure the verification service is running:

```shell
( cd ${TOPDIR}/services/verification/cmd && ./verification-service )
```
### Exchanging evidence with the Verifier

In a new bourne shell session

```shell
export TOPDIR=$(pwd)
```

```shell
go install github.com/veraison/evcli@demo-psa-1.0.0
```

```shell
cd ${TOPDIR}/docs/demo/psa/prov-verif-e2e
```

* Verifying Evidence as a Relying party with the Veraison Verifier

1. First create Evidence using supplied templates

```shell
evcli psa create -c data/templates/psa-claims-profile-2.json -k data/keys/ec-p256.jwk --token=psa-evidence.cbor
```
` >> "psa-evidence.cbor" successfully created `

2. Exchange Evidence with the Verification Service

* Verifying as a Relying Party

```shell
evcli psa verify-as relying-party --api-server=http://localhost:8080/challenge-response/v1/newSession --token=psa-evidence.cbor
```

* Verifying as an Attester

```shell
evcli psa verify-as attester --api-server=http://localhost:8080/challenge-response/v1/newSession --claims=data/templates/psa-claims-profile-2-without-nonce.json --key=data/keys/ec-p256.jwk --nonce-size=32
```

* Log checking

1. On VTS plugin window(where VTS is running) one should see the debug print: `plugin.scheme-psa-iot:  Token Signature Verified` & `matchSoftware Success` 

2. On Verification window one should see Appraisal Context indicating Success
