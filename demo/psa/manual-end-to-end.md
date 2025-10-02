# PSA Demonstration Steps

This document explains all the steps one need to follow to successfully run
end to end PSA Demonstration.

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

1. **Protocol Buffer Compiler (protoc)**
   
   Download the latest pre-compiled `protoc` binary from [Protocol Buffers releases](https://github.com/protocolbuffers/protobuf/releases).
   
   For Ubuntu/Linux x86_64:
   ```sh
   # Download and install protoc (replace VERSION with latest, e.g., 25.1)
   curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-linux-x86_64.zip
   unzip protoc-25.1-linux-x86_64.zip -d $HOME/.local
   export PATH="$PATH:$HOME/.local/bin"
   ```
   
   For macOS:
   ```sh
   # Download and install protoc for macOS
   curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.1/protoc-25.1-osx-x86_64.zip
   unzip protoc-25.1-osx-x86_64.zip -d $HOME/.local
   export PATH="$PATH:$HOME/.local/bin"
   ```
   
   For Windows:
   ```powershell
   # Download protoc-25.1-win64.zip from the releases page and extract to a directory
   # Add the bin directory to your PATH environment variable
   ```
   
   To verify installation:
   ```sh
   protoc --version
   ```

2. **Go Protocol Buffer Plugin (protoc-gen-go) version v1.26**
   
   > **Important**: This is separate from protoc and must be installed via Go:
   
   ```sh
   go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.26.0
   ```
3. **protoc-gen-go-grpc version v1.1**
   ```sh
   go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1
   ```

4. **protoc-gen-go-json version v1.1.0**
   ```sh
   go install github.com/mitchellh/protoc-gen-go-json@v1.1.0
   ```

5. **mockgen version v1.6.0**
   ```sh
   go install github.com/golang/mock/mockgen@v1.6.0
   ```

### Troubleshooting

If you encounter issues with the above installation:

**protoc not found:**
- Ensure `$HOME/.local/bin` is in your `$PATH`
- Try `which protoc` to verify installation location
- For system-wide installation, extract to `/usr/local` instead of `$HOME/.local`

**protoc-gen-go not found:**
- Verify Go is properly installed: `go version`
- Ensure `$GOPATH/bin` (or `$HOME/go/bin`) is in your `$PATH`
- Try `which protoc-gen-go` to verify the plugin is available
- If using Go modules, the default GOPATH is `$HOME/go`

**Permission issues:**
- Use `sudo` for system-wide installation of protoc
- For Go packages, avoid `sudo` as they install in user space

**Build failures with "protoc-gen-go: program not found or is not executable":**
- This indicates protoc cannot find the protoc-gen-go plugin
- Verify both protoc and protoc-gen-go are installed and in PATH
- Try running: `protoc-gen-go --version` to test the plugin directly

**Note:** protoc (the compiler) and protoc-gen-go (the Go plugin) are separate tools that must both be installed for Go protocol buffer generation to work.

* Commands below assume execution in a Bourne-compatible shell. Please adjust appropriately in case any other shell is used.


## Creation of PSA Endorsements

First create new Concise Module Identifiers (CoMID's) and use them in creating Concise Reference Integrity Manifests (CoRIM's) using reference templates located under `docs/demo/psa/prov-verif-e2e/data/templates` to provision them in Veraison Verification Service.

More details about CoRIM and CoMID can be found [here](https://datatracker.ietf.org/doc/draft-ietf-rats-corim/)

### Initial Setup

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

* Remember this shell as shell-1. 

### Create CoMID's

```shell
cd ${TOPDIR}/docs/demo/psa/prov-verif-e2e
```

* Create CoMID for Trust Anchors using given JSON template

Please inspect template JSON file `data/templates/comid-psa-iak-pub.json` and modify anything as per your requirement

```shell
cocli comid create --template=data/templates/comid-psa-iak-pub.json
```

One should see, created "comid-psa-iak-pub.cbor" from "data/templates/comid-psa-iak-pub.json"

* Create CoMID for Reference Values using given JSON template

Please inspect template JSON file `data/templates/comid-psa-refval.json`and modify anything as per your requirement

```shell
cocli comid create --template=data/templates/comid-psa-refval.json
```
One should see, created "comid-psa-refval.cbor" from "data/templates/comid-psa-refval.json"

### Create CoRIM

* Create a single CoRIM from Trust Anchor and Reference Value CoMID and using given JSON template CoRIM Wrapper

```shell
cocli corim create --template=data/templates/corim-full.json --comid=comid-psa-iak-pub.cbor --comid=comid-psa-refval.cbor
```
created "corim-full.cbor" from "data/templates/corim-full.json"

### Using newly generated CoRIM's
Move the generated CORIM above to data/cbor directory
 
```shell
mv corim-full.cbor  data/cbor/
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
git clone --branch demo-psa-1.0.1 https://github.com/veraison/services
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
VTS Service starts all the supported plugins (scheme-psa-iot, scheme-tcg-dice, scheme-tpm-enacttrust for now)

Go back to shell-1, used for Creation of PSA Endorsements

Ensure that you are under docs/demo/psa/prov-verif-e2e directory:

```shell
cd ${TOPDIR}/docs/demo/psa/prov-verif-e2e
```

Ship the single CORIM that contains PSA reference values and trust anchor from data/cbor folder using following commands


```shell
cocli corim submit --corim-file=data/cbor/corim-full.cbor --api-server="http://localhost:8888/endorsement-provisioning/v1/submit" --media-type="application/corim-unsigned+cbor; profile=http://arm.com/psa/iot/1"
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
