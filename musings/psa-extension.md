# INTRODUCTION

This document describes how the existing ARM PSA profile can be extended
to incorporate specific requirement of the user applications to support
user data attestation.

Throughout the document, RATS Passport Based Model is used.

## Purpose 

The document solves two main purpose.

* Describe a procedure that allows Client Applications to bind application 

provided "user data" to the ARM PSA Attestation Context.

* It provides client applications enough details that enable them to build a binding

layer beneath their applications which undertake full Passport based Attestation Protocol

with an Attestation Verification Service, such as Veraison and return an Attestation Result

as a Passport.

### BACKGROUND

The native ARM PSA Platform API as documented [here](https://arm-software.github.io/psa-api/attestation/1.0/IHI0085-PSA_Certified_Attestation_API-1.0.3.pdf)
allows a client to request an Attestation Evidence (claims pertaining to the platform) 

from the underlying platform by passing the "Freshness Parameter" known as "nonce"

to get the Attesation token which is known as Evidence in the RATS protocol.

### Extended PSA Evidence

In order to bind the client supplied "user data" to the PSA Evidence the 

PSA Evidence is augmented. The CDDL definition of the Augmented Evidence is as under:

extendedPsaEvidence = {

    "utoken" => UCCS-UAT,

    "pat" => PSA-token

}

UCCS-UAT = <TBD601>({

  &(eat_nonce: 10) => bstr .size (8..64) ; received freshness parameter from Verification Service

  &(data: -7000) => bstr ; Supplied user data from the client

  &(alg: -7001) => txt  ; The algorithm used to hash the utoken 

})

* Details of the extendedPSAEvidence

1. `pat`: An ARM PSA Attestation token as define in [here](https://datatracker.ietf.org/doc/draft-tschofenig-rats-psa-token/). Note that this token represents the entire credential issued by the PSA Root of Trust

2. `utoken` : A sidecar token used to link the application supplied user data to the PSA Platform token

* Cryptographic linkage of "utoken" with "pat"

In order to cryptographically link "utoken" with "pat", the sequence to be followed is as under:

Upon receipt of "user data" from client application, 

a. The binding layer initiates a Session with the "Attestation Verification Service" and receives
a "nonce" from the Service. The session intiation details can be found [here](https://github.com/veraison/docs/tree/main/api/challenge-response#challengeresponse)

b. The binding layer encodes a "utoken" as a CBOR data

c. The encoded "utoken" is hashed using a suitable hash algorithm as detailed in the utoken

d. The Hash("utoken") is used as a "challenge parameter" to obtain the `pat` from the underlying PSA platform

* CBOR data produced by encoding bytes .cbor extendedPsaEvidence is used as a attestation token that is sent to Verification Service (Veraison) to obtain the Attestation Results

* A new mediaType defined, as `application/eat-collection; profile=http://arm.com/psa-extension/1.0.0`
will be used to exchange this Evidence. This needs to be set in ContentType when submitting Evidence

The exact steps are detailed [here](https://github.com/veraison/docs/tree/main/api/challenge-response)


### Enhancements to Veraison 
In order to support the extended PSA evidence Veraison Verification will be enhanced to:

1. Support new Media type, i.e. "application/eat-collection; profile=http://arm.com/psa-extension/1.0.0"

2. Veraison will support decoding of the extended PSA Evidence.

3. A new Verification Plugin will be added to support Verification based on 
   the new attestation scheme for psa extension

4. A new Veraison extension will be added to the Eat Attestation Result[EAR](https://github.com/veraison/ear)to support setting the user data received from the Extended PSA Evidence, upon successful verification of the received Evidence