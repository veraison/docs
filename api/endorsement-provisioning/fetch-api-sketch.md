# Fetch API

Just a sketch of one possible design to kick off the discussion.

## Fetching a Trust Anchor

### PSA IoT Profile

* Request:

```HTTP
POST /endorsement-provisioning/v1/fetch
Host: veraison.example
Content-Type: application/vnd.veraison.trustanchor-id+json; profile=http://arm.com/psa/iot/1

{
  "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig==",
  "psa.inst-id": "Ac7rrnuJJ6MiflMDz14PH3s0u1Qq1yUKwD+83jbsLxUI"
}
```

* Response:

```http
200 OK
Content-Type: application/vnd.veraison.trustanchor+json; profile=http://arm.com/psa/iot/1

{
  "id": {
    "type": "PSA_IOT",
    "parts": {
      "psa.hw-model": "RoadRunner",
      "psa.hw-vendor": "ACME",
      "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig==",
      "psa.inst-id": "Ac7rrnuJJ6MiflMDz14PH3s0u1Qq1yUKwD+83jbsLxUI"
    }
  },
  "value": {
    "type": "RAWPUBLICKEY",
    "value": {
      "psa.iak-pub": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEFn0taoAwR3PmrKkYLtAsD9o05KSM6mbgfNCgpuL0g6VpTHkZl73wk5BDxoV7n+Oeee0iIqkW3HMZT3ETiniJdg=="
    }
  }
}
```


### EnactTrust Profile

* Request:

```HTTP
POST /endorsement-provisioning/v1/fetch
Host: veraison.example
Content-Type: application/vnd.veraison.trustanchor-id+json; profile=http://enacttrust.com/veraison/1.0.0

{
  "enacttrust-tpm.node-id": "2170bfcf-a08f-43b5-915b-d6e820164035"
}
```

* Response:

```http
200 OK
Content-Type: application/vnd.veraison.trustanchor+json; profile=http://enacttrust.com/veraison/1.0.0

{
  "id": {
    "type": "TPM_ENACTTRUST",
    "parts": {
      "enacttrust-tpm.node-id": "2170bfcf-a08f-43b5-915b-d6e820164035"
    }
  },
  "value": {
    "type": "RAWPUBLICKEY",
    "value": {
      "enacttrust.ak-pub": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6Vwqe7hy3O8Ypa+BUETLUjBNU3rEXVUyt9XHR7HJWLG7XTKQd9i1kVRXeBPDLFnfYru1/euxRnJM7H9UoFDLdA=="
    }
  }
}
```

## Fetching Software Components

### PSA IoT Profile

* Request:

```http
POST /endorsement-provisioning/v1/fetch
Host: veraison.example
Content-Type: application/vnd.veraison.swcomponent-id+json; profile=http://arm.com/psa/iot/1

{
  "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig=="
}
```

* Response:

```http
200 OK
Content-Type: application/vnd.veraison.swcomponent+json; profile=http://arm.com/psa/iot/1

[
  {
    "id": {
      "type": "PSA_IOT",
      "parts": {
        "psa.hw-model": "RoadRunner",
        "psa.hw-vendor": "ACME",
        "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig==",
        "psa.measurement-type": "PRoT",
        "psa.signer-id": "rLsRx+TaIXIFUjzkzhokWuGiOa48a/2eeHH35di66Gs=",
        "psa.version": "1.3.5"
      }
    },
    "attributes": {
      "psa.measurement-desc": 1,
      "psa.measurement-value": "AmOCmYm2/ZVPcrqvL8ZLwuLwHWktTecphuqAj26ZgT8="
    }
  },
  {
    "id": {
      "type": "PSA_IOT",
      "parts": {
        "psa.hw-model": "RoadRunner",
        "psa.hw-vendor": "ACME",
        "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig==",
        "psa.measurement-type": "ARoT",
        "psa.signer-id": "rLsRx+TaIXIFUjzkzhokWuGiOa48a/2eeHH35di66Gs=",
        "psa.version": "0.1.4"
      }
    },
    "attributes": {
      "psa.measurement-desc": 1,
      "psa.measurement-value": "o6XnFfDMV0pzw/m+u2vCTzL/1bZ7OHJEwskJ2neaFHg="
    }
  }
]
```

### EnactTrust Profile

* Request:

```http
POST /endorsement-provisioning/v1/fetch
Host: veraison.example
Content-Type: application/vnd.veraison.swcomponent-id+json; profile=http://enacttrust.com/veraison/1.0.0

{
  "enacttrust-tpm.node-id": "ffffffff-ffff-ffff-ffff-ffffffffffff"
}
```

* Response:

```http
200 OK
Content-Type: application/vnd.veraison.swcomponent+json; profile=http://enacttrust.com/veraison/1.0.0

{
  "id": {
    "type": "TPM_ENACTTRUST",
    "parts": {
      "enacttrust-tpm.node-id": "ffffffff-ffff-ffff-ffff-ffffffffffff"
    }
  },
  "attributes": {
    "enacttrust-tpm.alg-id": 1,
    "enacttrust-tpm.digest": "h0KPxSKAPTEGXnvOPPA/5HUJZjHl4Hu9eg/eYMTPJcc="
  }
}
```

## Software Component ID

### PSA IoT

* (M) `psa.impl-id` is the PSA Implementation ID in base64-urlsafe encoding
* (O) `psa.hw-vendor` is a vendor identifier as a UTF-8 string
* (O) `psa.hw-model` is the device model identifier as a UTF-8 string

```json
{
  "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig==",
  "psa.hw-vendor": "ACME",
  "psa.hw-model": "RoadRunner"
}
```

### TPM EnactTrust

* (M) `enacttrust-tpm.node-id` is the UUID node identifier in string format

```json
{
  "enacttrust-tpm.node-id": "2170bfcf-a08f-43b5-915b-d6e820164035"
}
```

## Trust Anchor

### PSA IoT

* (M) `psa.impl-id` is the PSA Implementation ID in base64-urlsafe encoding
* (M) `psa.inst-id` is the PSA Instance ID in base64-urlsafe encoding

```json
{
  "psa.impl-id": "IllXTnRaUzFwYlhCc1pXMWxiblJoZEdsdmJpMXBaQzB3TURBd01EQXdNREU9Ig==",
  "psa.inst-id": "AUyj5PUL8kjDl4cCDWj/0FyIdndRvyZFypI/V6mL7NKW"
}
```

### TPM EnactTrust

* (M) `enacttrust-tpm.node-id` is the UUID node identifier in string format

```json
{
  "enacttrust-tpm.node-id": "2170bfcf-a08f-43b5-915b-d6e820164035"
}
```
