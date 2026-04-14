# Endorsement Provisioning Interface

The API described here are can be used to provision 
Endorsements into a Verifier. The API are agnostic with regards to 
the specific data model used to transport Endorsements. HTTP Content negotiation is used to determine the precise message structure and format of the information exchanged between the clients and the server. 
One specific example of information exchange using
[Concise Reference Integrity Manifest (CoRIM)](https://datatracker.ietf.org/doc/draft-birkholz-rats-corim/) is given below.

## Provisioning API

The provisioning API allows authorized supply chain actors to communicate reference and endorsed values,
verification and identity key material, as well as other kinds of endorsements to Veraison. The supported 
format is CoRIM.

* To initiate a provisioning session, a client `POST`'s the CoRIM containing the endorsements to be provisioned to the `/submit` URL.
* If the transaction completes synchronously, a `200` response is returned to the client to indicate the
  submission of the posted CoRIM has been fully processed.  The response body contains a "session" resource whose `status` field encodes the outcome of the submission (see below).
* The provisioning processing may also happen asynchronously, for example when submitting a large CoRIM. In this case,
  the server returns a `201` response, with a `Location` header pointing to a session resource that the client can regularly poll to monitor any change in the status of its request.
* A session starts in `processing` state and ends up in one of `success` or `failed`. When in `failed` state, the `failure-reason` field of the session resource contains details about the error condition.
* The session resource has a defined time to live: upon its expiry, the resource is garbage collected.  Alternatively, the client can dispose the session resource by issuing a `DELETE` to the resource URI.

## Synchronous submission

```text
 o        (1) POST           .-------------.
/|\ ------------------------>| /submit     |
/ \ <------------------------|             |
            200 (OK)         '-------------' 
            { "status": "success|failed" }
```

* Client submits the endorsement provisioning request
* Server responds with response code `200` indicating processing is complete.
  The response body contains a session resource with a `status` indicating the outcome of the submission operation.

### Example of a successful submission

```text
>> Request:
  POST /endorsement-provisioning/v1/submit
  Host: veraison.example
  Content-Type: application/rim+cbor

  ...CoRIM as binary data...

<< Response:
  HTTP/1.1 200 OK
  Content-Type: application/vnd.veraison.provisioning-session+json

  {
    "status": "success",
    "expiry": "1970-01-01T00:00:00Z"
  }
```

### Example of a failed submission

```text
>> Request:
  POST /endorsement-provisioning/v1/submit
  Host: veraison.example
  Content-Type: application/rim+cbor

  ...CoRIM as binary data...

<< Response:
  HTTP/1.1 200 OK
  Content-Type: application/vnd.veraison.provisioning-session+json

  {
    "status": "failed",
    "failure-reason": "invalid signature",
    "expiry": "1970-01-01T00:00:00Z"
  }
```

## Asynchronous submission

```text
 o        (1) POST           .-------------.
/|\ ------------------------>| /submit     |
/ \ \ <----------------------|             |
   \ \      201 Created      '-------------'
    \ \     Location: /session/01   |
     \ \                            V
      \ \  (2) GET           .-------------.
       \ '------------------>| /session/01 |
        `<-------------------|             |
             200 OK          '-------------'
             { "status": "processing|success|failed" }
```


* Client submits the endorsement provisioning request
* Server responds with response code `201` indicating that the request has been accepted and will be processed asynchronously
* Server returns the URI of a time-bound session resource in the `Location` header. The resource can be polled at regular intervals to check the progress of the submission, until the processing is complete (either successfully or with a failure)

### Example

```text
>> Request:
  POST /endorsement-provisioning/v1/submit
  Host: veraison.example
  Content-Type: application/rim+cbor

...CoRIM as binary data...
  
<< Response:
  HTTP/1.1 201 Created
  Content-Type: application/vnd.veraison.provisioning-session+json
  Location: /endorsement-provisioning/v1/session/1234567890

  {
    "status": "processing",
    "expiry": "2030-10-12T07:20:50.52Z"
  }
```

```text
>> Request:
  GET /endorsement-provisioning/v1/session/1234567890
  Host: veraison.example
  Accept: application/vnd.veraison.provisioning-session+json

<< Response:
  HTTP/1.1 200 OK
  Content-Type: application/vnd.veraison.provisioning-session+json

  {
    "status": "success",
    "expiry": "2030-10-12T07:20:50.52Z"
  }
```

# Endorsement Lifecycle Management Interface

This interface can be used for activating/deactivating endorsements provisioned
to the verifier. Two modes are supported:

1. Using CoRIM/CoMID ids
2. Using CoSERV query

In the first mode, a collection of CoRIM/CoMID ids (or a combination of both)
can be submitted, to activate/deactivate all endorsements that came from those
CoRIM/CoMIDs. The collection of IDs are structured in a JSON document:

```json
{
    "profile": "tag:example.com,2025/example-profile",
    "corim-ids": ["82702896-9ced-4952-88f4-8c1dc2c8af20"],
    "comid-ids": ["6720f8cb-6594-493a-8fb7-f1bdff446eb5", "101ef8a1-0e72-449a-a1d2-031ee206b2f0"]
}
```

In the second mode, a CoSERV query is submitted and all the endorsements that
match the selection are activated/deactivated. The `result-type` field in
CoSERV query are ignored.


## Examples

### Activating a combination of CoRIMs and CoMIDs
Activate a set of CoRIMs and CoMIDs using the `activate` API.

#### Request

```
POST /endorsement-provisioning/v1/activate
Host: veraison.example
Content-Type: application/vnd.veraison.endorsement-id-collection+json

{
    "profile": "tag:example.com,2025/example-profile",
    "corim-ids": ["82702896-9ced-4952-88f4-8c1dc2c8af20"],
    "comid-ids": ["6720f8cb-6594-493a-8fb7-f1bdff446eb5", "101ef8a1-0e72-449a-a1d2-031ee206b2f0"]
}
```

#### Response

```
HTTP/1.1 204 No Content
```

### Activating using CoSERV
Activate the trust anchors for the instance-ids `0x1234` and `0x2345`.

#### Request
```
POST /endorsement-provisioning/v1/activate
Host: veraison.example
Content-Type: application/coserv+cbor; profile="tag:vendor.com,2025/example-profile"

-- body in EDN
{
    / profile / 0: "tag:vendor.com,2025/example-profile",
    / query / 1: {
        / artifact-type /           0: 1, / trust-anchors /
        / environment-selector /    1: {
            / instance / 1: [ [h'1234'], [h'2345'] ]
        }
        / result-type / 2: 0    / collected-artifacts /
    }
}
```

#### Response
```
HTTP/1.1 204 No Content
```


### Deactivating a CoMID
Deactivating endorsements from a single CoMID

#### Request
```
POST /endorsement-provisioning/v1/deactivate
Host: veraison.example
Content-Type: application/vnd.veraison.endorsement-id-collection+json

{
    "profile": "tag:example.com,2025/example-profile",
    "comid-ids": ["101ef8a1-0e72-449a-a1d2-031ee206b2f0"]
}   
```

#### Response
```
HTTP/1.1 204 No Content
```

### Deactivating using CoSERV
Deactivate all reference values for a particular class of devices:

#### Request
```
POST /endorsement-provisioning/v1/deactivate
Host: veraison.example
Content-Type: application/coserv+cbor; profile="tag:vendor.com,2025/example-profile"

-- body in EDN
{
    / profile / 0: "tag:vendor.com,2025/example-profile",
    / query / 1: {
        / artifact-type /           0: 2, / reference-values /
        / environment-selector /    1: {
            / class / 0: {
                [
                    [{ / model / 2: "model2" }]
                ]
            }
        }
        / result-type / 2: 0    / collected-artifacts /
    }
}
```

#### Response
```
HTTP/1.1 204 No Content
```
