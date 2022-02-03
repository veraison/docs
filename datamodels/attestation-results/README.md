## Attestation Results

This directory contains a JSON/CBOR serialisation based on the information model described in the [Attestation Results for Secure Interactions](https://datatracker.ietf.org/doc/draft-ietf-rats-ar4si/) Internet-Draft.

Veraison produces its attestation results (i.e., the output of attestation evidence appraisal) in the format specified by the files in the [grammar](grammar) directory, which also contains a number of [examples](grammar/examples) for both CBOR and JSON serialisations.

The grammar is specified using [CDDL](https://datatracker.ietf.org/doc/rfc8610/) whilst the examples are in CBOR [diagnostic](https://datatracker.ietf.org/doc/html/rfc8949#section-8) notation.
