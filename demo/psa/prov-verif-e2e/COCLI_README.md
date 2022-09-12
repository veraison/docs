# Creation of PSA Endorsements 

Follow below instructions if one wishes to create new Concise Module Identifiers (CoMID's) and use them in creating Concise Reference Integrity Manifests (CoRIM's) using reference templates located under `docs/demo/psa/prov-verif-e2e/data/templates` to provision them in Veraison Verification Service.

More details about CoRIM and CoMID can be found [here](datatracker.ietf.org/doc/draft-ietf-rats-corim/)

## Initial Setup

Do this ONLY if it is not done already:

In a new bourne shell session

```shell
export TOPDIR=$(pwd)
```

* Install `cocli` tool using following command

```shell
go install github.com/veraison/corim/cocli@demo-psa-1.0.0
```

```shell
git clone https://github.com/veraison/docs
```

## Create CoMID's

```shell
cd ${TOPDIR}/docs/demo/psa/prov-verif-e2e
```

* Create CoMID for Trust Anchors using given JSON template

Please inspect template JSON file `data/templates/comid-psa-iak-pub.json` and modify anything as per your requirement

```shell
cocli comid create --template=data/templates/comid-psa-iak-pub.json
```

* Create CoMID for Reference Values using given JSON template

Please inspect template JSON file `data/templates/comid-psa-refval.json`and modify anything as per your requirement

```shell
cocli comid create --template=data/templates/comid-psa-refval.json
```
created "comid-psa-refval.cbor" from "data/templates/comid-psa-refval.json"

## Create CoRIM

* Create a single CoRIM from Trust Anchor and Reference Value CoMID and using given JSON template CoRIM Wrapper

```shell
cocli corim create --template=data/templates/corim-full.json --comid=comid-psa-iak-pub.cbor --comid=comid-psa-refval.cbor
```
created "corim-full.cbor" from "data/templates/corim-full.json"

## Using newly generated CoRIM's
Move the generated CORIM above to data/cbor directory
 
```shell
mv corim-full.cbor  data/cbor/
```