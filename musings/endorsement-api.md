# Endorsement API

This musing discusses the addition of a new Veraison service that provides an [Endorsement API](https://wiki.ietf.org/en/group/rats/referencevalues) endpoint.

In the reminder of this musing, we will use the shorthand "EAPI" to refer to this new service.

## Simplifying Assumptions

At this stage, this work is intended as a proof-of-concept, therefore we will make a few simplifying assumptions:

1. Arm CCA only
2. Simplified RBAC model with fixed tenant
3. Transactional (request-response) API
4. API output in [rust-ccatoken](https://github.com/veraison/rust-ccatoken/blob/main/src/store/data-model.cddl) format

These choices minimise the amount of new client code required while still creating many of the necessary building blocks on the server side.

## New bits and pieces

EAPI will be added as a new service alongside the existing [verification](), [management]() and [provisioning]() components.

Strictly speaking, EAPI depends only on [VTS]() (Veraison trusted services) which is the exclusive owner of the stores from which the endorsements are fetched.
EAPI is likely to execute in combination with the provisioning service, which allows ingesting up-to-date endorsements from "upstream" endorsers and reference value providers via its push API.
In an EAPI-driven deployment, the verification service can be muted.
(Full blown RBAC support will need integration with KeyCloak; this can be deferred to a later stage.)

EAPI exposes a REST API endpoint over HTTPS that allows a client to retrieve "endorsements" (i.e., reference values and trust anchors) pertaining to a given attester ((A) in the figure below.)

Since the endorsement stores are owned by the VTS component, one or more [gRPC services](https://github.com/veraison/services/blob/main/proto/vts.proto) (B) need to be defined to allow EAPI to query the stores (C) through VTS.
Their exact shape will be driven by the interface offered by the external REST API.

VTS will be extended to receive the query via the new gRPC service, create the corresponding query (or queries) to the stores and forward the result set back to EAPI.
EAPI will repackage the results according to the REST spec and send them in the HTTP response to the client.

If needed, scheme-specific query adapters will be encapsulated in a "EAPI query plugin" (D).

```
.--------.            .------.     .-----.     .--------.
| Vfying |            |      |     |     |     |'------'|
| RP     +----o )-----+ EAPI +-----+ VTS +-----+ Stores |
|        |        (A) |      | (B) |     | (C) |        |
'--------'            '------'     '--+--'     '--------'
                                      | (D)
                                  .---+---.
                                  |query  |
                                  |plugin |
                                  '-------'
```


