# Services management

The API described here are intended to assist with the operation and management
of a Veraison services deployment. They are not meant to be utilized by the
services' users.

## Policy management

Policies allow augmenting attestation scheme generated [Attestation Results] on
per-deployment basis, by specifying additional rules to be applied to these
results. This may result in the change of the trust vector values (and,
correspondingly, the overall result status), and/or addition of supplementary
claims under the `policy-added-claims` EAR extension.

A policy is defined by a text document describing the rules to be applied by
the policy engine. Currently, Veraison only support the OPA policy engine.
Correspondingly, policies must be written in Rego language used by OPA. See
[OPA policy README] in services repo for details.

During verification, the active policy for attestation scheme/tenant
combination is retrieved. Currently, only one policy per scheme/tenant may be
active at a time.

The policy management API exposes each scheme's policy via a unique resource
path in the form `/policy/v1/{scheme}`. It supports the basic CRUD operations,
typical to any resource management, in the following way:

- **create**: A new policy is added to a scheme via a POST request to its path.
- **read**: Policy can be retrieved via a GET request to its path.
- **update**: A direct update is not possible, however a new policy can be
              added and activated. Activating the new policy will deactivate
              the old one, effectively replacing it.
- **delete**: True deletion is not possible. This allows retrieval of the
              specific policy version that was used to generate an attestation
              result. However, all policies may be deactivated, resulting in no
              policy being used during verification.

[Attestation Results]: https://www.rfc-editor.org/rfc/internet-drafts/draft-fv-rats-ear-00.html
[OPA Policy README]: https://github.com/veraison/services/blob/main/policy/README.opa.md#rules

## REST API

### Adding a new policy

- A policy is added for a new scheme (with tenant implicit via auth).
- Optionally, a name for the policy may be specified via query arguments. If a
  name is not specified, the default name of `"default"` will be used.
- On success, the new policy object is returned, with Location header set to
  its unique URI.
- The newly added policy is inactive. It must be activated via  a separate
  request (see below).

#### Request:
```http
POST /management/v1/policy/PSA_IOT&name=base HTTP/1.1
Host: veraison.example
Content-Type: application/vnd.veraison.policy.opa
Accept: application/vnd.veraison.policy+json

hardware = "AFFIRMING" {
    // secured state
    state := bits.rsh(bits.and(evidence["psa-security-lifecycle"], 0xFFFF0000), 8)
    state >= 0x3000
    state <= 0x30FF
} else = "CONTRAINDICATED"
```

#### Response:
```http
HTTP/1.1 201 Created
Content-Type: application/vnd.veraison.policy+json
Location: /management/v1/policy/PSA_IOT/340d22f7-9eda-499f-9aa2-5af295d6d812

{
  "type": "opa",
  "name": "base",
  "uuid": "340d22f7-9eda-499f-9aa2-5af295d6d812",
  "active": false,
  "ctime": "2023-07-06 00:00:00",
  "rules": "hardware = \"AFFIRMING\" {\n          // secured state\n          state := bits.rsh(bits.and(evidence[\"psa-security-lifecycle\"], 0xFFFF0000), 8)\n          state >= 0x3000\n          state <= 0x30FF\n      } else = \"CONTRAINDICATED\"\n  }"
}
```

### Retrieving a specific policy object

A policy may be retrieved via its unique URI.

#### Request:
```http
GET /management/v1/policy/PSA_IOT/340d22f7-9eda-499f-9aa2-5af295d6d812 HTTP/1.1
Host: veraison.example
Accept: application/vnd.veraison.policy+json
```

#### Response:
```http
HTTP/1.1 200 OK
Content-Type: application/vnd.veraison.policy+json

{
  "type": "opa",
  "name": "base",
  "uuid": "340d22f7-9eda-499f-9aa2-5af295d6d812",
  "active": false,
  "ctime": "2023-07-06 00:00:00",
  "rules": "hardware = \"AFFIRMING\" {\n          // secured state\n          state := bits.rsh(bits.and(evidence[\"psa-security-lifecycle\"], 0xFFFF0000), 8)\n          state >= 0x3000\n          state <= 0x30FF\n      } else = \"CONTRAINDICATED\"\n  }"
}
```

### Retrieving the active policy object

The active policy object for a scheme may be retrieved by omitting the UUID.

#### Request:
```http
GET /management/v1/policy/PSA_IOT HTTP/1.1
Host: veraison.example
Accept: application/vnd.veraison.policy+json
```

#### Response:
```http
HTTP/1.1 200 OK
Content-Type: application/vnd.veraison.policy+json

{
  "type": "opa",
  "name": "base",
  "uuid": "ae19cc27-a449-1fb8-6c10-00f47ad1c55c",
  "active": true,
  "ctime": "2023-07-06 00:00:00",
  "rules": "hardware = \"AFFIRMING\"  // always affirm"
}
```

### Retrieving all policy objects for a scheme

Optionally, a name query param may be used to filter the result and only return
policies for the scheme associated with the specified name.

#### Request:
```http
GET /management/v1/policies/PSA_IOT&name=base HTTP/1.1
Host: veraison.example
Accept: application/vnd.veraison.policy+json
```

#### Response:
```http
HTTP/1.1 200 OK
Content-Type: application/vnd.veraison.policies+json

[
  {
    "type": "opa",
    "name": "base",
    "uuid": "ae19cc27-a449-1fb8-6c10-00f47ad1c55c",
    "active": true,
    "ctime": "2023-07-06 00:00:00",
    "rules": "hardware = \"AFFIRMING\"  // always affirm"
  },
  {
    "type": "opa",
    "name": "base",
    "uuid": "340d22f7-9eda-499f-9aa2-5af295d6d812",
    "active": false,
    "ctime": "2023-07-06 00:00:00",
    "rules": "hardware = \"AFFIRMING\" {\n          // secured state\n          state := bits.rsh(bits.and(evidence[\"psa-security-lifecycle\"], 0xFFFF0000), 8)\n          state >= 0x3000\n          state <= 0x30FF\n      } else = \"CONTRAINDICATED\"\n  }"
  }
]
```

### Activate a policy

Set a given policy to become the active one. This operation atomically
deactivates any previously active policy for the scheme.

#### Request:
```http
POST /management/v1/policy/PSA_IOT/340d22f7-9eda-499f-9aa2-5af295d6d812/activate HTTP/1.1
Host: veraison.example
```

#### Response:
```http
HTTP/1.1 200 OK
```

### Deactivate all policies

#### Request:
```http
POST /management/v1/policies/PSA_IOT/deactivate HTTP/1.1
Host: veraison.example
```

#### Response:
```http
HTTP/1.1 200 OK
```
