# Veraison in a TEE

## Abstract Model

A Veraison services workload ($V$) runs in a TEE ($P$).

###  Keys

$P$ has its own attestation key pair $\langle \mathcal SK_P, \mathcal PK_P \rangle$.

At start-up, $V$ generates its signing key-pair $\langle \mathcal SK_V, \mathcal PK_V \rangle$.

* $V \rightarrow P$ : $h(\mathcal PK_V)$
* $V \leftarrow  P$ : $\epsilon$

where $\epsilon := \epsilon[P_{t_{i}}, W_{t_{i}}, h(\mathcal PK_V), t_{i}]_{\mathcal SK_P}$

### Appraisal

We assume a pre-existing trust relationship between $R$ and $P$, i.e.: $R$ trusts $\mathcal PK_P$ to be associated with $P$.

When appraisal is requested by a relying party $R$ (or an attester, if in passport mode), $V$ replies with an attestation result $\alpha[\ldots]_{\mathcal SK_V}$ that, along with the appraisal result for the submitted evidence ($E$), contains the most recently obtained workload and key attestation:

* $R \rightarrow V$ : $E$
* $R \leftarrow  V$ : $\alpha{[\ldots, \epsilon]}_{\mathcal SK_V}$

The relying party (or an auditor in its stead) can verify that:

* The key used to sign the attestation result matches the attested key ($\mathcal PK_V$ is either published at a known location, or inlined in the attestation result);
* The security state of platform and workload is as expected, and that their measurements are fresh enough.

This binding scheme guarantees that $V$'s identities (both as a cryptographic signer, and as a piece of running code & configuration) cannot be separated, which prevents a _forwarding_ attack where a rogue verifier $\tilde{V}$ can use platform evidence not correlated to the outer signing key -- obtained in some way from a genuine verifier $V$ -- to trick $R$ into thinking that platform and workload security state is as expected.

**Note:** if $t_{i}$'s are paced with a frequency that is $\gg$ than the number of expected appraisals from the same $R$, a hash of $\epsilon$ can be used instead, which reduces bandwidth requirements.

## Nitro Instantiation

When run in a Nitro Enclave, the abstract protocol elements are instantiated using the following claims in the `AttestationDocument` payload:

* $P_{t_{i}}$: there is no such thing in Nitro, one has to trust AWS via the AWS Nitro Attestation PKI, which includes a root certificate for the commercial AWS partitions.
* $W_{t_{i}}$:
  1. `pcrs["PCR0"]` (Enclave image file),
  1. `pcrs["PCR1"]` (Linux kernel and bootstrap), and
  1. `pcrs["PCR2"]` (Application)
* $h(\mathcal PK_V)$: `public_key`
* $t_i$: `timestamp`
* $\mathcal SK_P$: `certificate`

The complete `AttestationDocument` is provided below:

```cddl
AttestationDocument = {
    module_id: text,               ; issuing Nitro hypervisor module ID
    timestamp: uint .size 8,       ; UTC time when document was created, in
                                   ; milliseconds since UNIX epoch
    digest: digest,                ; the digest function used for calculating the
                                   ; register values
    pcrs: { + index => pcr },      ; map of all locked PCRs at the moment the
                                   ; attestation document was generated
    certificate: cert,             ; the infrastructure certificate used to sign this
                                   ; document, DER encoded
    cabundle: [* cert],            ; issuing CA bundle for infrastructure certificate
    ? public_key: user_data,       ; an optional DER-encoded key the attestation
                                   ; consumer can use to encrypt data with
    ? user_data: user_data,        ; additional signed user data, defined by protocol
    ? nonce: user_data,            ; an optional cryptographic nonce provided by the
                                   ; attestation consumer as a proof of authenticity
}

cert = bytes .size (1..1024)       ; DER encoded certificate
user_data = bytes .size (0..1024)
pcr = bytes .size (32/48/64)       ; PCR content
index = 0..31
digest = "SHA384"
```

###  Notes

1. The signed `AttestationDocument` can be stored in the discovery API endpoint of the verification frontend in a `ear-verification-key-attestation` claim.
1. We could use `user_data` in case we want to stash Veraison-specific data in the `AttestationDocument`, for example as a bstr-wrapped CBOR/JSON map.
1. The `nonce` field is conveniently optional, which plays well with our timestamp-based freshness model.
