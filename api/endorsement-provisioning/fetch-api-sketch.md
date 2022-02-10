# Retrieval API

Just a sketch of one possible design to kick off the discussion.

## Fetching a Trust Anchor

```http
>> Request:
  POST /endorsement-provisioning/v1/fetch
  Host: veraison.example
  Content-Type: application/vnd.veraison.trustanchor-id+json; profile=...

  ...JSON-ified id of the resource to fetch (see below)...

<< Response:
  HTTP/1.1 200 OK
  Content-Type: application/vnd.veraison.trustanchor+json; profile=...

  ...trust anchor (including meta) as JSON object...
```

## Fetching Software Components

```http
>> Request:
  POST /endorsement-provisioning/v1/fetch
  Host: veraison.example
  Content-Type: application/vnd.veraison.swcomponent-id+json; profile=...

  ...JSON-ified id of the resource to fetch (see below)...

<< Response:
  HTTP/1.1 200 OK
  Content-Type: application/vnd.veraison.swcomponent+json; profile=...

  ...sw components as JSON array...
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