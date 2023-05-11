
# Verification Machinery

## Verification From Ten Thousand Feet

The picture below is yet another way to slice the [RATS architecture](https://www.rfc-editor.org/rfc/rfc9334.html#figure-1), which makes the (important) distinction between _"identity endorsements"_ (e.g., verification keys), and _"endorsed values"_ (e.g., certification status of the gadget, color, etc.), which is not explicit in RFC9334.

This distinction becomes relevant when zooming in to the [appraisal process](#a-closer-look-to-the-appraisal-process) where one kind or the other is used depending on the verification "stage."

```mermaid
flowchart TD
    R[(reference</br>values)]
    Ev[(endorsed</br>values)]
    Ei[(identity</br>endorsement)]
    P[(appraisal policy</br>for evidence)]
    VO([verifier</br>owner])
    RFP([reference</br>value</br>provider])
    E([endorser])
    RP([relying</br>party])
    A([attester])
    e((Evidence))
    a((Attestation</br>Result))
    V([verifier])

    subgraph " "
    Ev
    Ei
    end

    subgraph " "
    R
    end
    
    subgraph " "
    P
    end

    VO --> P
    RFP --> R
    E --> Ev
    E --> Ei
    P --> V
    R --> V
    RP --> e
    A --> e
    Ev --> V
    Ei --> V
    V --> a
    e --> V
    A -.-> RP

```

## A Closer Look to the Appraisal Process

The picture below provides a closer look in to the appraisal process, describing what a typical verification flow could look like.  The flow is broken down into four separate stages:

* [Crypto verification](#crypto-verification)
* [Reference values match](#reference-values-match)
* [Endorsed values decoration](#endorsed-values-decoration)
* [Attestation result assembly and signing](#attestation-result-assembly-and-signing)

> **Notes**:
>
> * The appraisal policy is an input to all the processing stages
> * All non-final processing stages can output a "failure" signal that short circuits the appraisal
  
```mermaid
flowchart TD
    v1[crypto</br>verification]
    v2[refval</br>match]
    v3[endorsed values</br>decoration]
    v4[AR assembly</br>and signing]
    Ei[(identity</br>endorsement)]
    e((Evidence))
    P[(appraisal policy</br>for evidence)]
    skV>verifier signing key]
    a((Attestation</br>Result))
    R[(reference</br>values)]
    Ev[(endorsed</br>values)]

    subgraph " "
    Ev
    Ei
    end

    subgraph " "
    R
    end
    
    subgraph " "
    P
    end

    subgraph stages[" "]
    v1
    v2
    v3
    v4
    end

    subgraph " "
    skV
    end

    e --> v1
    Ei --> v1
    v1 -- evidence claims-set --> v2
    P --> stages
    v2 -- evidence claims-set --> v3
    v3 -- evidence claims-set</br>derived claims-set --> v4
    skV --> v4
    v4 --> a
    R --> v2
    Ev --> v3
    v1 -- failure -->v4
    v2 -- failure -->v4
```

### Crypto Verification

> Input:
>
> * Evidence to be verified
> * Identity endorsements

1. Look up the matching identity endorsement (e.g., a raw public key, a trust anchor, etc.)
1. Use the key material to verify the Evidence's cryptographic envelope

> Output:
>
> * the (cryptographically verified) Evidence's claims-set

```mermaid
flowchart TD
    v1[crypto</br>verification]
    Ei[(identity</br>endorsement)]
    e((Evidence))
    P[(appraisal policy</br>for evidence)]
    Ecs((evidence</br>claims-set))
    FAIL((("failure")))

    v1 --> FAIL
    Ei --> v1
    e --> v1
    v1 --> Ecs
    P --> v1
```

### Reference Values match

> Input:
>
> * Evidence claims-set
> * Reference values

1. Look up any applicable reference values
1. Match reference values against the claims-set

> Output:
>
> * (validated) Evidence claims-set

```mermaid
flowchart TD
    v2[refval</br>match]
    P[(appraisal policy</br>for evidence)]
    R[(reference</br>values)]
    Ecs1((evidence</br>claims-set))
    Ecs2((evidence</br>claims-set))
    FAIL((("failure")))

    v2 --> FAIL
    v2 --> Ecs2
    R --> v2
    Ecs1 --> v2
    P --> v2
```

### Endorsed Values Decoration

> Input:
>
> * The Evidence claims-set
> * Endorsed values

1. Look up applicable endorsed values
1. decide (based on policy) which endorsed values can be added to the claims-set

> Output:
>
> * Evidence claims-set
> * Derived claims-set

```mermaid
flowchart TD
    v3[endorsed values</br>decoration]
    P[(appraisal policy</br>for evidence)]
    Ev[(endorsed</br>values)]
    Ecs1((evidence</br>claims-set))
    Ecs2((evidence</br>claims-set))
    Dcs((derived</br>claims-set))
    FAIL((("failure")))

    Ev --> v3
    Ecs1 --> v3
    v3 --> FAIL
    v3 --> Dcs
    v3 --> Ecs2
    P --> v3
```

### Attestation Result assembly and signing

> Input:
>
> * Evidence and Derived claims-set, or a failure signal
> * the Verifier private key that signs the attestation result

1. Determine the attestation result claims-set based on the input claims-set and policy
1. Sign the final attestation result statement

> Output:
>
> * Signed attestation results

```mermaid
flowchart TD
    v4[AR assembly</br>and signing]
    P[(appraisal policy</br>for evidence)]
    skV>verifier signing key]
    a((Attestation</br>Result))
    Ecs((evidence</br>claims-set))
    Dcs((derived</br>claims-set))
    FAIL((("failure")))

    FAIL --> v4
    Ecs --> v4
    Dcs --> v4
    P --> v4
    skV --> v4
    v4 --> a
```
