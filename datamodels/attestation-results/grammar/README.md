## Validation suite

Invoke `make(1)` to run the full validation suite.

## Required tooling

`cddl(1)` and the CBOR diagnostic tools (specifically, `diag2cbor.rb` and `diag2diag.rb`) are a prerequisite to run the grammar checks and validating the [examples](examples).

To install (depending on the host, you may need `sudo(1)` powers):
```shell
gem install cddl cbor-diag
```
