## Attestation Results

Veraison's attestation result format, which was once described at this place, is now superseded by [EAR](https://datatracker.ietf.org/doc/draft-fv-rats-ear).

If you need to ask questions about EAR, feel free to join [this Zulip stream](https://veraison.zulipchat.com/#narrow/stream/357929-EAR/).

If you want to use EAR in your codebase, the Veraison project provides three separate implementations:

* [`veraison/ear`](https://github.com/veraison/ear), a Golang package that allows encoding, decoding, signing and verification of EAR payloads together with a CLI ([`arc`](https://github.com/veraison/ear/tree/main/arc)) to create, verify and visualize EARs on the command line.
* [`C EAR`](https://github.com/veraison/c-ear), a C17 library that allows verification and partial decoding of EAR payloads.
* [Rust EAR](https://github.com/veraison/rust-ear), a Rust (2021 edition) library that allows verification and decoding of EAR payloads.
