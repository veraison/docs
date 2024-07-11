# Platform

|Bucket|Notes|Claims|Applicability|
| --- | --- | --- | --- |
|Catch-all||VERIFIER_MALFUNCTION|any unexpected exceptions during the appraisal/verification flow|
|||NO_CLAIM|This MAY be the value for the buckets that are not applicable (i.e., those marked as “N.A.”), if they are included.|
|||UNEXPECTED_EVIDENCE|On failures coming from the token decoder|
|||CRYPTO_VALIDATION_FAILED|On failures coming from the Platform token verifier (excluding Realm binding, which is captured in the Realm part)|
|Instance identity||TRUSTWORTHY_INSTANCE|verification using CPAK is successful and Implementation ID is known (implicitly, from the fact that ref-values associated to it exist)|
|||UNTRUSTWORTHY_INSTANCE|If the verifier has a notion of known-bad CPAK, then verification using CPAK that is successful but CPAK is known-bad can assert this claim.|
|||UNRECOGNIZED_INSTANCE|No CPAK found corresponding to the Instance ID or Implementation ID is not known (i.e., there are no ref-values associated to it.)|
|Config|Two notions of config in CCA may apply: (a) the “System Properties” captured in the Platform “config” claim, (b) the firmware and/or hardware configuration file that can be specified by certain boot loader stages. Those end up in sw-components entries of type “*_CONFIG”|APPROVED_CONFIG|TBD[^1] decide on what semantics we want to map here.|
|||NO_CONFIG_VULNS|ditto|
|||UNAVAIL_CONFIG_ELEMS|ditto|
|||UNSAFE_CONFIG|ditto|
|||UNSUPPORTABLE_CONFIG|ditto|
|Executables|This conflates boot and run-time and makes disentangling “partial match” situations impossible.|APPROVED_BOOT|If all sw-component claims have been verified|
|||APPROVED_RUNTIME|N.A.|
|||CONTRAINDICATED_RUNTIME|N.A.|
|||UNRECOGNIZED_RUNTIME|N.A.|
|||UNSAFE_RUNTIME|N.A.|
|File system||APPROVED_FILES|N.A.|
|||UNRECOGNIZED_FILES|N.A.|
|||CONTRAINDICATED_FILES|N.A.|
|Hardware (and Firmware)||CONTRAINDICATED_HARDWARE (genuine HW/FW but contraindicated)|TRUSTWORTHY_INSTANCE && some sw-component claims are known-bad|
|||UNRECOGNIZED_HARDWARE (unrecognised HW/FW)|TRUSTWORTHY_INSTANCE && some sw-component claims couldn’t be found|
|||GENUINE_HARDWARE (genuine HW/FW)|Same as (TRUSTWORTHY_INSTANCE && APPROVED_BOOT)|
||Not clear what is the difference between this and CONTRAINDICATED_HARDWARE?|UNSAFE_HARDWARE (genuine HW/SW but known sec vulns)|TBD (see note)|
|Sourced Data||CONTRAINDICATED_SOURCES|N.A.|
|||TRUSTED_SOURCES|N.A.|
|||UNTRUSTED_SOURCES|N.A.|
|Runtime opaque||ENCRYPTED_MEMORY_RUNTIME|Depends on the settings of the config claim?  Or can it be assumed for any genuine RME?[^2]|
|||ISOLATED_MEMORY_RUNTIME|See above[^3]|
|||VISIBLE_MEMORY_RUNTIME|N.A.|
|(persistent) Storage opaque||HW_KEYS_ENCRYPTED_SECRETS|TBD|
|||SW_KEYS_ENCRYPTED_SECRETS|ditto|
|||UNENCRYPTED_SECRETS|ditto|

[^1]: SimonF: The Platform config definitely comes into play here as the context is that the host needs to be equipped for confidential operation and hence the RME extension needs to be shown as enabled. 
To be detailed in analysis of the firmware contribution for 'config' contributions, there are those sw component entries that are config blobs rather than FW binaries which can need verification. 
It could also be said that config also covers checks that certain FW items (roles?) are present e.g an RMM
ThomasF: I am having trouble understanding how the two semantics (i.e., boot loader(s) configuration vs ISA configuration) can co-exist with each other in the same TV claim.  It looks like the intention of AR4SI config as currently specified ("A Verifier has appraised an Attester's configuration, and is able to make conclusions regarding the exposure of known vulnerabilities") is more naturally mapped to the former (i.e., boot loader's) than the latter - mostly because I wouldn't know how to "make conclusions regarding the exposure of known vulnerabilities" based on the platform's config claim alone.
SimonF: Agreed. I think the original doc misses the nuisance of HW configuration affecting this ability.
ThomasF: yeah, that's a "very" gray area.  I was pondering whether making platform's config fall into the hardware.GENUINE_HARDWARE basket, but it's probably not a huge improvement.

[^2]: SimonF: This is a bit tricky because the presence & config of a Memory Protection Engine is Impdef. It should show up in the same sys properties that are used to show RME so we could note that it's profile capable.  Remind me: is this setting bitwise or absolute - i.e. can we have both Encrypted + Isolated for this entry or does it have to be one or the other?
ThomasF: it's absolute: basically, ENCRYPTED absorbs ISOLATED

[^3]: SimonF: Any system known to be RME capable and configured can claim ISOLATED. We could just do this from platform config but potentially also ImplementationID
ThomasF: OK, so this can be implied if (tv.instance_identity == TRUSTWORTHY_INSTANCE) && (platform.config & RME_CAPABLE) ?

# Realm

|Bucket|Notes|Claims|Applicability|
| --- | --- | --- | --- |
|Catch-all||VERIFIER_MALFUNCTION|any unexpected exceptions during the appraisal/verification flow|
|||NO_CLAIM|This MAY be the value for the buckets that are not applicable (i.e., those marked as “N.A.”), if they are included.  Alternatively, if platform appraisal fails flat, this can be the value that all Realm buckets are reset to (meaning: since platform is not successfully appraised, we cannot say anything about Realm integrity)|
|||UNEXPECTED_EVIDENCE|On failures coming from the Realm token decoder|
|||CRYPTO_VALIDATION_FAILED|on failures coming from the Realm token verifier (not including the binding to the Platform token, which is dealt with in the instance identity category as UNRECOGNIZED_INSTANCE)|
|Instance identity||TRUSTWORTHY_INSTANCE|If crypto verification (including chaining) completes correctly|
|||UNTRUSTWORTHY_INSTANCE|N.A.|
|||UNRECOGNIZED_INSTANCE|If crypto verification is OK but chaining fails|
|Config||APPROVED_CONFIG|N.A.|
|||NO_CONFIG_VULNS|N.A.|
|||UNAVAIL_CONFIG_ELEMS|N.A.|
|||UNSAFE_CONFIG|N.A.|
|||UNSUPPORTABLE_CONFIG|N.A.|
|Executables|It looks like an “UNRECOGNIZED_BOOT” is missing… but really the problem here is that this claim conflates run-time and boot-time.|APPROVED_BOOT|if RIM and PV (if provided) match|
|||APPROVED_RUNTIME|if REM match|
|||CONTRAINDICATED_RUNTIME|If the verifier has a notion of known-bad REM values (alongside known-good) this can be set in case REM matches known-bad values|
|||UNRECOGNIZED_RUNTIME|If no REM ref-values match evidence|
||Not clear how this differs from CONTRAINDICATED_RUNTIME|UNSAFE_RUNTIME|(could be used as an alternative to CONTRAINDICATED_RUNTIME in the warning tier)|
|File system||APPROVED_FILES|N.A.|
|||UNRECOGNIZED_FILES|N.A.|
|||CONTRAINDICATED_FILES|N.A.|
|Hardware (and Firmware)||CONTRAINDICATED_HARDWARE|N.A.|
|||UNRECOGNIZED_HARDWARE|N.A.|
|||GENUINE_HARDWARE|N.A.|
|||UNSAFE_HARDWARE|N.A.|
|Sourced Data||CONTRAINDICATED_SOURCES|N.A.|
|||TRUSTED_SOURCES|N.A.|
|||UNTRUSTED_SOURCES|N.A.|
|Runtime opaque||ENCRYPTED_MEMORY_RUNTIME|If platform appraisal is successful, the value for this can be copied from platform|
|||ISOLATED_MEMORY_RUNTIME|ditto|
|||VISIBLE_MEMORY_RUNTIME|ditto|
|(persistent) Storage opaque||HW_KEYS_ENCRYPTED_SECRETS|TBD[^4]|
|||SW_KEYS_ENCRYPTED_SECRETS|ditto|
|||UNENCRYPTED_SECRETS|ditto|

[^4]: SimonF: The AR4SI spec has a slight config here: the intro says 'capable of encrypting persistent storage' but the values says that that this storage is specific to secrets.  If we take the view this is just secrets centric then the presence of a HES should imply HW protection.  If a mechanism for general persistent storage, then we're in Impdep territory.
ThomasF: For context, AR4SI references https://www.gsma.com/newsroom/wp-content/uploads/2012/03/omtpadvancedtrustedenvironmentomtptr1v11.pdf#page=53 which seems to have the mobile segment as primary scope, and a very specific idea of what "opaque storage" means (quite similar to PSA secure storage BTW).  I may be off but it looks like the gist is the protection of user secrets rather than platform secrets?  If so, what can be deduced from evidence about the feature being available to Realms?  If it's IMPDEP then we could just say that this bucket is N.A. unless a verifier is intimate with the implementation.
