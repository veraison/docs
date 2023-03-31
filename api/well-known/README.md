# Discovery APIs
The APIs described here allow a user of the Veraison to obtain and view meta information about the Veraison deployment. Information about a deployment can be queried according to the service - e.g., provisioning or verification.

The relevant resource is created in response to a client `GET`. The queried information is then outputted as shown in the examples below.

## Well-known API: Provisioning service
The information for the provisioning service has the following attributes:

* The allowed provisioning media types;
* The version of the provisioning service;
* The current operational state of the service;
* The exposed API endpoints and the corresponding URLs (relative to the request's base URL).

### Querying information about the Provisioning service

- Request:
```http
GET /.well-known/veraison/provisioning
Host: veraison.example
```

- Response:
```http
HTTP/1.1 200 OK
Content-format: application/vnd.veraison.discovery+json

{
  "media-types": [
    "application/corim-unsigned+cbor; profile=http://arm.com/cca/ssd/1",
    "application/corim-unsigned+cbor; profile=http://arm.com/psa/iot/1",
    "application/corim-unsigned+cbor; profile=http://enacttrust.com/veraison/1.0.0"
  ],
  "version": "commit-a8056d0",
  "state": "READY",
  "api-endpoints": {
    "provisioningSubmit": "/endorsement-provisioning/v1/submit"
  }
}
```


## Well-known API: Verification service
The information for the verification service has the following attributes:

* The public key used to verify the Attestation Result;
* The allowed media types for attestation evidence;
* The version of the verification service;
* The current operational state of the service;
* The exposed API endpoints and the corresponding URLs (relative to the base URL).


### Querying information about the Verification service

- Request:
```http
GET /.well-known/veraison/verification
Host: veraison.example
```

- Response:
```http
HTTP/1.1 200 OK
Content-format: application/vnd.veraison.discovery+json

{
  "ear-verification-key": {
    "alg": "ES256",
    "crv": "P-256",
    "kty": "EC",
    "x": "usWxHK2PmfnHKwXPS54m0kTcGJ90UiglWiGahtagnv8",
    "y": "IBOL-C3BttVivg-lSreASjpkttcsz-1rb7btKLv8EX4"
  },
  "media-types": [
    "application/eat-collection; profile=http://arm.com/CCA-SSD/1.0.0",
    "application/psa-attestation-token",
    "application/eat-cwt; profile=http://arm.com/psa/2.0.0",
    "application/pem-certificate-chain",
    "application/vnd.enacttrust.tpm-evidence"
  ],
  "version": "commit-a8056d0",
  "state": "READY",
  "api-endpoints": {
    "newChallengeResponseSession": "/challenge-response/v1/newSession"
  }
}
```
