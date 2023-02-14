# CCA Demonstration Steps

This document explains all the steps one need to follow to successfully run
end to end CCA Platform Verification Demonstration.

## Preconditions

### Install on Ubuntu 
* One needs to install `Go`, `jq`,`sqlite3`,`tmux` and `curl`.

Use the below mentioned path to install go in your system:

`https://go.dev/doc/install`

Installing jq:
```sh
sudo apt update && sudo apt install jq && jq --version
```

Installing sqlite3:
```sh
sudo apt update
sudo apt install sqlite3 
sqlite3 --version
```
You will get an output like this:
`3.31.1 2020-01-27 19:55:54 3bfa9cc97da10598521b342961df8f5f68c7388fa117345eeb516eaa837balt1`

Installing curl:
```sh
sudo apt install curl
```

Installing tmux:
```sh
sudo apt-get install tmux
```


* For build to succeed one needs to install following packages:
1. protoc-gen-go with version v1.26
From  `https://github.com/protocolbuffers/protobuf/releases` download the `protobuf-all-[VERSION].tar.gz`.
Extract the contents and change in the directory

```sh
./configure
make
make check
sudo make install
```
To check if this works
`protoc --version`

2. protoc-gen-go-grpc version v1.1
`go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1`
3. protoc-gen-go-json version v1.1.0
`go install github.com/mitchellh/protoc-gen-go-json@v1.1.0`
4. mockgen version v1.6.0
`go install github.com/golang/mock/mockgen@v1.6.0`

### Other systems

* One need to install jq and curl.


* For build to succeed one needs to install following packages:
1. protoc-gen-go with version v1.26
2. protoc-gen-go-grpc version v1.1
3. protoc-gen-go-json version v1.1.0
4. mockgen version v1.6.0

* Commands below assume execution in a Bourne-compatible shell. Please adjust appropriately in case any other shell is used.


## Creation of CCA Endorsements

First create new Concise Module Identifiers (CoMID's) and use them in creating Concise Reference Integrity Manifests (CoRIM's) using reference templates located under `docs/demo/cca/prov-verif-e2e/data/templates` to provision them in Veraison Verification Service.

More details about CoRIM and CoMID can be found [here](https://datatracker.ietf.org/doc/draft-ietf-rats-corim/)

### Initial Setup

Do this ONLY if it is not done already:
PLEASE NOTE: Setup instructions are same between PSA and CCA demonstration.

In a new bourne shell session

```shell
export TOPDIR=$(pwd)
```

* Install `cocli` tool for provisioning endorsements using following command

```shell
go install github.com/veraison/corim/cocli@demo-cca-1.0.0
```

* Install `arc` tool for decoding attestation results using the following command

```shell
go install github.com/veraison/ear/arc@demo-cca-1.0.0
```

```shell
git clone https://github.com/veraison/docs
```

* Remember this shell as shell-1. 

### Create CoMID's

```shell
cd ${TOPDIR}/docs/demo/cca/prov-verif-e2e
```

* Create CoMIDs for CCA Trust Anchors and Reference Values using given JSON template

Please inspect template JSON file `data/templates/comid-cca-ta-endorsements.json`  to provision cca trust anchors (ta) and modify anything as per your requirement

Please inspect template JSON file `data/templates/comid-cca-mult-refval.json` to provision cca reference values and modify anything as per your requirement

Using single command one can create two CBOR files for two CoMIDs from above json templates

```shell
cocli comid create --template=data/templates/comid-cca-ta-endorsements.json \
                    --template=data/templates/comid-cca-mult-refval.json
```

One should see, on the console
created "comid-cca-ta-endorsements.cbor" from "data/templates/comid-cca-ta-endorsements.json"
created "comid-cca-mult-refval.cbor" from "data/templates/comid-cca-mult-refval.json"

### Create CoRIM

* Create a single CoRIM using given CoRIM JSON template and supplying CBOR Trust Anchor and Reference Value CoMIDs from above

```shell
cocli corim create --template=data/templates/corim-cca.json --comid=comid-cca-ta-endorsements.cbor --comid=comid-cca-mult-refval.cbor
```
created "corim-cca.cbor" from "data/templates/corim-cca.json"

### Using newly generated CoRIM
Move the generated CORIM above to data/cbor directory
 
```shell
mv corim-cca.cbor  data/cbor/
```
* Please retain this shell, as shell-1 as you would need to come back here at the time of provisioning the endorsements.

## Provisioning pipeline setup

To run provisioning test you need two parallel shell sessions.

In each shell, move to the directory location where you are going to clone the GIT repo and do:

```shell
export TOPDIR=$(pwd)
```

### Steps

In the first shell, clone the Veraison services repository:

```shell
git clone https://github.com/veraison/services@demo-cca-1.0.0
```

Build the services:

```shell
make -C ${TOPDIR}/services
```

Start the REST API frontend:

```shell
( cd ${TOPDIR}/services/provisioning/cmd/provisioning-service && ./provisioning-service )
```

In another shell create the KV stores:

```shell
( cd ${TOPDIR}/services/vts/cmd/vts-service && ./../../test-harness/init-kvstores.sh )
````

Then start the VTS service:

```shell
( cd ${TOPDIR}/services/vts/cmd/vts-service && ./vts-service )
```
VTS Service starts all the supported plugins (scheme-psa-iot, scheme-tcg-dice, scheme-tpm-enacttrust, scheme-cca-ssd-platform for now)

Go back to shell-1, used for Creation of CCA Endorsements

Ensure that you are under docs/demo/cca/prov-verif-e2e directory:

```shell
cd ${TOPDIR}/docs/demo/cca/prov-verif-e2e
```

Ship the single CORIM that contains CCA reference values and trust anchor from data/cbor folder using following commands


```shell
cocli corim submit --corim-file=data/cbor/corim-cca.cbor --api-server="http://localhost:8888/endorsement-provisioning/v1/submit" --media-type="application/corim-unsigned+cbor; profile=http://arm.com/cca/ssd/1"
```

The REST frontend should return a success status.

The success of post API status can be noticed in console logs of front end (provisioning-service) likewise below...

`[GIN] 2022/09/09 - 17:39:55 | 200 | 49.977785ms | 127.0.0.1 | POST "/endorsement-provisioning/v1/submit"`

If so, you can inspect the KV stores to check what has been generated:

* Verification keys:

```shell
sqlite3 ${TOPDIR}/services/vts/cmd/vts-service/ta-store.sql 'select distinct vals from kvstore' | jq .
```

* Reference values:

```shell
sqlite3 ${TOPDIR}/services/vts/cmd/vts-service/en-store.sql 'select distinct vals from kvstore' | jq .
```

### Cleanup

Use Ctrl-C to stop the REST provisioning frontend in shells 1 (as one
would not need provisioning service once the Reference Values and
Endorsements are now provisioned into Verification service)

## Verification pipeline setup

If not already done, ensure the verification service is running:

```shell
( cd ${TOPDIR}/services/verification/cmd/verification-service && ./verification-service )
```
### Exchanging evidence with the Verifier

In a new shell session

```shell
export TOPDIR=$(pwd)
```

```shell
go install github.com/veraison/evcli@demo-cca-1.0.0
```

```shell
cd ${TOPDIR}/docs/demo/cca/prov-verif-e2e
```

* Verifying Evidence as a Relying party with the Veraison Verifier

1. First create Evidence using supplied templates

```shell
evcli cca create --claims=data/templates/cca-claims.json --pak=data/keys/ec256.jwk --rak=data/keys/ec384.jwk --token=cca-evidence.cbor
```
` >> "cca-evidence.cbor" successfully created `

2. Exchange Evidence with the Verification Service

* Verifying as a Relying Party

```shell
evcli cca verify-as relying-party --api-server=http://localhost:8080/challenge-response/v1/newSession --token=cca-evidence.cbor | tr -d '"' > ear.jwt
```

The above command writes a Entity Attestation Result (ear) as a signed JSON Web Token in file ear.jwt

* Decoding the contents of Entity Attestation Result

One can cryptogrpahically verify the `ear.jwt` returned from Veraison and decode the contents using `arc` CLI tool as below:

arc verify -a=ES256  -p=data/keys/verif_es256_pub.jwk ear.jwt


* Verifying as an Attester

```shell
evcli cca verify-as attester --api-server=http://localhost:8080/challenge-response/v1/newSession --claims=data/templates/cca-claims-without-realm-challenge.json --pak=data/keys/ec256.jwk --rak=data/keys/ec384.jwk | tr -d '"' > ear.jwt
```
Now decode the Entity Attestation Results using `arc` tool as given above

* Log checking

1. On VTS plugin window(where VTS is running) one should see the debug print: `plugin.scheme-cca-ssd-platform:  Token Signature Verified`,  `matchSoftware Success` & `matchPlatformConfig Success`

2. On Verification window one should see Appraisal Context indicating Success
