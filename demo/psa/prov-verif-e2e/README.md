# PSA Demonstration Steps

This document explains all the steps one need to follow to successfully run
end to end PSA Demonstration.

## Preconditions

* One need to install `jq` and `curl`.

* For build to succeed one needs to install following packages:
1. protoc-gen-go with version v1.26
2. protoc-gen-go-grpc version v1.1
3. protoc-gen-go-json version v1.1.0
4. mockgen version v1.6.0

* Commands below assume execution in a Bourne-compatible shell. Please adjust appropriately in case any other shell is used.

## Creation of PSA Endorsements

* The Supply Chain Endorsements used in provisioning pipeline setup below are created using the instructions given [here](./COCLI_README.md) Use these instructions if one wants to create their own Endorsements or modify existing ones.

## Provisioning pipeline setup

* Install `cocli` tool using following command

In a new shell session

```shell
go install github.com/veraison/corim/cocli@demo-psa-1.0.0
```

To run provisioning test you need three parallel shell sessions.

In each shell, move to the directory location where you are going to clone the GIT repo and do:

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
( cd ${TOPDIR}/services/vts/cmd && ../test-harness/init-kvstores.sh )
````

Then start the VTS service:

```shell
( cd ${TOPDIR}/services/vts/cmd && ./vts-service )
```
VTS Service starts all the supported plugins (scheme-psa-iot, scheme-tcg-dice, scheme-tpm-enacttrust for now)

In the third shell

```shell
git clone https://github.com/veraison/docs
```

Move to the docs/demo/psa/prov-verif-e2e directory:

```shell
cd ${TOPDIR}/docs/demo/psa/prov-verif-e2e
```

Ship the single CORIM that contains PSA reference values and trust anchor from data/cbor folder using following command

```shell
cocli corim submit --corim-file=data/cbor/corim-full.cbor --api-server="http://localhost:8888/endorsement-provisioning/v1/submit" --media-type="application/corim-unsigned+cbor; profile=http://arm.com/psa/iot/1"
```

The REST frontend should return a success status.

The success of post API status can be noticed in console logs of front end (provisioning-service) likewise below...

`[GIN] 2022/09/09 - 17:39:55 | 200 | 49.977785ms | 127.0.0.1 | POST "/endorsement-provisioning/v1/submit"`

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

In a new shell session

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
