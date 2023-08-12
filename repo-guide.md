# Repo Guide

The following is a quick overview of the Veraison repos. This is a selective list to help get started navigating the work under the Project Veraison organisation. For a full list of repos, see: https://github.com/orgs/veraison/repositories?type=all

Unless specified, code repos are Golang based

## Core Code

[services](https://github.com/veraison/services)
This is the main repo holding the code implementing the attestation verification components that can be used to create a service. 

[docs](https://github.com/veraison/docs)
Veraison documentation

## Project 
[community](https://github.com/veraison/community)
Veraison community files. Look here for introductory presentations to the project and CCC membership materials.

[veraison.github.io](https://github.com/veraison/veraison.github.io) 
Currently a placeholder for veraison-project.org.

## Client Libraries
Veraison services expose REST APIs. This set of libraries provides convenient code abstractions for the API model, to be used in client verification and provisioning applications.

[apiclient](https://github.com/veraison/apiclient): Veraison API client implementation in Go
[rust-apiclient](https://github.com/veraison/rust-apiclient): Veraison API client implementation in Rust
[c-apiclient](https://github.com/veraison/c-apiclient): Veraison API client implementation in C


## Architecture specific libs
This collection of libraries provides manipulation and verification functionality for Attestation formats of various architectures. 

[psatoken](https://github.com/veraison/psatoken): Platform Security Abstraction (PSA) Attestation Token manipulation library.
[ccatoken](https://github.com/veraison/ccatoken) 
A library for the Arm Confidential Computing Architecture (CCA) Attestation Token.
[dice](https://github.com/veraison/dice): library providing support functions for manipulating various profiles of DICE.
[parsec](https://github.com/veraison/parsec): Library support for handling the Parsec Key Attestation formats used in the attested TLS PoC.
[enact-demo](https://github.com/veraison/enact-demo): EnactTrust TPM/Veraison interop demo and related docs



## CLI tools 
CLI tools for illustrative interactions with attestation tokens or a Veraison service. Used for demos & integration testing.

[evcli](https://github.com/veraison/evcli) 
CLI for handling attestation evidence
[pocli]() 
Veraison services policy management client


## Standards driven work
The Veraison Project supports Attestation related working groups in standards bodies, in particular IETF & TCG. This set of repos provide test bed implementations for some of the standards work, as related to Veraison services.

#### EAT
[eat](https://github.com/veraison/eat) 
Golang library for manipulating Entity Attestation Tokens (draft-ietf-rats-eat).

#### EAR
These libraries provide functions for working with EAR (EAT Attestation Results), an EAT/JWT serialisation of the Attestation Result for Secure Interactions (AR4SI) information model - see draft-fv-rats-ear

[ear](https://github.com/veraison/ear): Golang implementation of EAT Attestation Results
[rust-ear](https://github.com/veraison/rust-ear): Rust implementation of EAT Attestation Results
[c-ear](https://github.com/veraison/ear): C implementation of EAT Attestation Results
 
[cmw](https://github.com/veraison/cmw): implementation for  RATS WG Conceptual Message Wrappers (draft-ftbs-rats-msg-wrap) for attestation related data encapsulation.

####  Verifier Provisioning 
These libraries provide support for the standard information models used to convey data to a Verifier.

[corim](https://github.com/veraison/corim): manipulation of Concise Reference Integrity Manifest (CoRIM) and Concise Module Identifier (CoMID) tags. Also includes cocli CLI tool, that assists users creating CoRIM & CoMID tags.

[swid](https://github.com/veraison/swid) : SWID and CoSWID manipulation library

#### COSE
[go-cose](https://github.com/veraison/go-cose): go library for CBOR Object Signing and Encryption (COSE)

## Veraison Repository Organisation

```mermaid
flowchart TD
VR("Veraison Roles")
style VR fill:#f9f,stroke:#333,stroke-width:4px
LG["<b>Logical Group</b> \n <i>Repository name</i>"]
subgraph Daigram[<b>Daigram Convention</b>]

VR  -->| Direct Usage | LG
VR  -.-> | Possible Usage | LG
LG  -->| Direct Dependency | LG
end

```

```mermaid
flowchart TD
subgraph Veraison["<b>Core Structure </b?"]
style Veraison stroke:#333,stroke-width:4px

SP("Supply Chain \n
                \n")
style SP fill:#f9f,stroke:#333,stroke-width:4px

ATT("Attester  \n
                \n")
style ATT fill:#f9f,stroke:#333,stroke-width:4px

COCLI["<b>Endorsement Manipulation CLI Tool</b>
 <i>cocli</i>"]

VPF["<b>Verifier Provisioning Formats</b>
 <i>corim</i>
 <i>coswid</i>"]
COCLI ---> VPF

CL["<b>Common Libraries</b> 
     <i>go-cose</i>"]

VPF ---> CL

EF["<b>Evidence Formats</b> 
     <i>dice</i>
     <i>eat</i>
     <i>psatoken</i>
     <i>ccatoken</i>
     <i>enacttrust-tpm</i>
     <i>parsec (tpm, cca)</i>"]
EF ---> CL

SD["<b>Core Verifier repositories</b> 
    <i>services</i> 
    <i>docs</i>"]

RP("Relying Party \n
                \n")
style RP fill:#f9f,stroke:#333,stroke-width:4px

AR["<b>Attestation Results</b> 
    <i>ear</i> 
    <i>c-ear</i>
    <i>rust-ear</i>"]
RP ---> AR

subgraph Verifier["Verifier"]
  style Verifier fill:#f9f,stroke:#333,stroke-width:4px
SD
end


Verifier ---> AR


Verifier ---> VPF
Verifier ---> CL
Verifier ---> EF

SP ---> COCLI

API["<b>API CLIENT LIBRARIES</b>
    <i>apiclient</i>
    <i>c-apiclient</i>
    <i>rust-apiclient</i>"]
SP  -.-> API

EVCLI["<b>Evidence Manipulation CLI Tool</b> \n <i>evcli</i> "]
EVCLI ---> API

CMW["<b>CONCEPTUAL MESSAGE WRAPPER</b>
      <i>cmw</i>"]

ATT --->EF
ATT -.-> EVCLI
EVCLI ---> EF
API ---> CMW
Verifier ---> CMW
POCLI["<b>Policy Mgmt CLI Tool</b>
      <i>pocli</i>"]

VO("Verifier Owner  \n
                \n")
style VO fill:#f9f,stroke:#333,stroke-width:4px

VO --> POCLI

POCLI ---> API

end
```

```mermaid
flowchart TD
VA["
    <i>community</i> 
    <i>veraison.github.io</i>"]
subgraph Veraison["<b>Administrative Repositories</b>"]
VA
end

```