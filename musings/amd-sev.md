# AMD Secure Encrypted Virtualization (AMD-SEV)

# Concepts
- AMD-SEV is targeted at securing virtual machines by encrypting the memory of each virtual machine with a unique key.
- SEV can protect your machine from a potentially malicious hypervisor.
- SEV can calculate a signature of virtual machine's memory content which can be sent to the VM's owner as an attestation that the memory on the target host, was encrypted correctly by firmware.
- AMD-SEV SNP is an extension to SEV which adds new hardware-based security protections

## Keys used in SEV
The AMD SEV firmware provides a mechanism to verify that it is executing on AMD hardware that supports SEV. The following key hierarchy, rooted in an AMD-owned key, is used in this process:

- $PDH$ (Platform Diffie Hellman) key - This key is used to negotiate a master secret which is then used with a key derivation function to establish a trusted channel
- $PEK$ (Platform Endorsement Key) - This key signs the $PDH$ to anchor the $PDH$ to the AMD root of trust and the platform owner's root of trust
- $CEK$ (Chip endorsement key) - This key signs the $PEK$ to anchor the $PEK$ to the AMD root of trust. Each chip has a unique $CEK$ which is derived from secrets stored in the chip's one-time programmable (OTP) memory
- $ASK$ (AMD Signing Key) - The $ASK$ private key signs the $CEK$ public key  to demonstrate that the $CEK$ is an authentic AMD key
- $ARK$ (AMD Root Key) - The $ARK$ private key signs the $ASK$ public key to demonstrate that the $ASK$ is an authentic AMD key. This key is the root of trust of AMD and its signatures signify AMD authencity

Therefore the following certificate chain is produced:


$ARK \rightarrow ASK \rightarrow CEK \rightarrow PEK \rightarrow PDH$


Therefore if the secure channel can be established using the $PDH$ key, then it is ensured that, the attesting workload is executed on, is an authentic AMD system which has the SEV feature.

## AMD-SEV SNP Attestation report measurements

### Platform measurements
- CHIP_ID - The unique chip identifier
- PLATFORM_INFO - Indicates properties of the platform configuration, for example whether whole system memory encryption (TSME) or simultaneous multithreading (SMT) is enabled
- CURRENT_TCB - Security Version Numbers (SVNs) of the current executing platform firmware and microcode
- COMMITTED_TCB - SVNs of the anti-rollback minimum of the platform firmware and microcode
- REPORTED_TCB - SVN of the hypervisor. The hypervisor has the option to report a lower version
- LAUNCH_TCB - SVNs of the platform firmware and microcode at the time the guest was launched or imported

### Guest measurements
- FAMILY_ID - The family ID of the guest that is provided at launch
- IMAGE_ID - The image ID of the guest that is provided at launch
- GUEST_SVN - The guest SVN
- MEASUREMENT - Measurement of the guest address space
- ID_KEY_DIGEST - SHA-384 digest of the ID public key that signed the [ID block](https://www.amd.com/system/files/TechDocs/56860.pdf#page=91) provided in `SNP_LAUNCH_FINISH`
- AUTHOR_KEY_DIGEST - SHA-384 digest of the Author public key that certified the ID key, if provided in `SNP_LAUNCH_FINISH`
- POLICY - The [guest policy](https://www.amd.com/system/files/TechDocs/56860.pdf#page=26)
- REPORT_ID - Report ID of this guest
- REPORT_ID_MA - Report ID of this guest's migration agent, if the guest is associated with a migration agent

More details on other elements of the produced attestation report are outlined [here](https://www.amd.com/system/files/TechDocs/56860.pdf#page=44).

# AMD-SEV SNP from Veraison's perspective
Veraison needs two things to verify the attestation of an AMD-SEV SNP system:

- The signed attestation report
    - $VCEK$ (Versioned Chip Endorsement Key) - The [$VCEK$](https://www.amd.com/system/files/TechDocs/57230.pdf) is the key that signs the attestation report. The key is derived from chip unique secrets and a [TCB_VERSION](https://www.amd.com/system/files/TechDocs/56860.pdf#page=18)
- The following certificate chain that is tied to the signed attestation report
    - $ARK \rightarrow ASK \rightarrow VCEK \rightarrow$ Attestation Report

## Current prototyping
A protoypte of an attestation verification flow is for AMD SEV-SNP evidence can be found [here](https://github.com/SabreenKaur/amd-snp-prototype). The library used for verification of the AMD SEV-SNP reports is [here](https://github.com/google/go-sev-guest).

### Structure of attestation verification flow
1. Report is obtained from attester
2. A full Attestation is derived from the report. In this step two things will happen to obtain the certificate chain (that forms part of this attestation):
    - AMD KDS (Key Distribution Service) is queried to get the ASK and ARK certificates if they are not already in the internal library cache
    - AMD KDS is queried to obtain the VCEK certificate if it is not already in the implemented time-to-live cache
3. Non-signature fields of the report are matched against a provided JSON policy
4. The Attestation is verified. Three things happen:
    - AMD KDS is queried to get the certificate chain (ASK, ARK and VECK) if they are not already in the their respective caches
    - Certificate revocation lists are checked
    - The Attestation report's signature is verified based on the report's signature algorithm

### Structure of the TTL (Time-to-live) cache
The implemented time-to-live cache is designed to hold:
- VCEK certificates
- CRLs (Certificate Revocation Lists)

Structure of the implemented cache:
- Key: `string` format of the url used to query the AMD KDS
- Value: `byte[]` format of the certificates or CRLs returned after querying the AMD KDS

Expiry of cache entries:
- VCEK certificates: time to live is set to be the duration between the current time and the `vcek.NotAfter` field. VCEK certificates typically expire every 7 years after being issued
- CRLs (Certificate Revocation Lists): time to live is set to be the duration between the current time and the `crl.NextUpdate` field. CRLs typically get refreshed every year

A [custom getter](https://github.com/SabreenKaur/amd-snp-prototype/blob/main/ttl_getter.go) is implemented to allow us to interface with the ttl cache.

### Veraison in a TEE with AMD SEV-SNP
- We can setup up an AWS EC2 instance with support for AMD SEV-SNP to obtain Attestation Reports.
    - Instructions on running the EC2 instance with AMD SEV SNP support are outlined [here](https://confluence.arm.com/display/~sabgur01/Creating+an+amd+sev+snp+instance+using+AWS+console)
- Reports can be obtain using this golang [library](https://github.com/google/go-sev-guest) (currently a [WIP](https://github.com/google/go-sev-guest/issues/53)) or using the AMD offical tooling following these [instructions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/snp-attestation.html). This [guide](https://confluence.arm.com/display/~sabgur01/Generating+a+VLEK+using+AMD+tools) helps with installing the modules needed to complete the steps in the instructions.
- Caveat: To verify SNP VMs within AWS, we need to obtain an VLEK instead of a VCEK certificate

## Open Questions
1. What sort of background tasks need to be performed behind the kvstore exisiting functionality, when querying the AMD key service? 
    - Does it need to be per scheme? 
    - What are the common logics?
- UPDATE: We can use ttl caches to store the certificates that are queried from the AMD KDS
2. Through what mechanism can we do the checking of CRLs (certificate revocation list) or similiar?
- UPDATE: This can be done by enabling the CheckRevocations in the Options struct 
3. How can platform (OCA) specific fields of the attestation report be verified? 
    - Could it be handled by policies?
4. Which non-signature fields of the attestation report should be validated by Veraison?
5. Where can nonce-like freshness data be represented? Possibly in the [REPORT_DATA](https://www.amd.com/system/files/TechDocs/56860.pdf#page=43) field?
6. Logic and functions within `trustedservices_grpc.GetAttestation` need to be refactored to account for that fact that trust anchors cannot be assumed in the SEV-SNP scheme, initial thoughts on functions to be refactored:
    - `initEvidenceContext(...)` - make it optional to `GetTrustAnchorID` within this function
    - `getTrustAnchor(...)` - make it optional to call this function

## References: 
1. [AMD SEV API specification](https://www.amd.com/system/files/TechDocs/55766_SEV-KM_API_Specification.pdf)
2. [AMD SEV-SNP ABI specification](https://www.amd.com/system/files/TechDocs/56860.pdf)
3. [AMD VCEK certificate and KDS interface specification](https://www.amd.com/system/files/TechDocs/57230.pdf)
4. [Presentation on attestation in AMD SEV-SNP](https://www.amd.com/content/dam/amd/en/documents/developer/lss-snp-attestation.pdf)
