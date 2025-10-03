# Veraison Terminology

This document explains the key concepts and terms used in **Project Veraison**.  
It is intended to help new contributors, developers, and users quickly understand the terminology.

---

## 🔹 Provisioning

### **CoRIM (Concise Reference Integrity Manifest)**
A data structure that provides trusted reference values (baselines) for attestation.  
It defines what "good" looks like for a platform or component.  
*(Defined in [IETF CoRIM draft](https://datatracker.ietf.org/doc/draft-birkholz-rats-corim/))*  

### **CoMID (Concise Module Identifier)**
A component of CoRIM that describes the identity and attributes of specific hardware or software modules.  
It enables precise matching of evidence with reference values.  

### **Endorsements**
Statements issued by manufacturers or trusted authorities about a device/component, describing capabilities, identity, or measurement expectations.

---

## 🔹 Verification

### **Evidence**
Claims collected from a device (the Attester) about its current state (firmware, boot configuration, runtime properties).  

### **Scheme**
A verification policy or method supported by Veraison that defines how evidence should be interpreted and matched against reference values.  

### **Verifier**
The entity that validates evidence against endorsements and reference values to produce an attestation result.  

### **Attestation Result**
The outcome of the verification process, usually expressing whether the evidence is trustworthy.  

---

## 🔹 Attestation Roles (from IETF RATS)

### **Attester**
The device or system that generates evidence about its state.  

### **Verifier**
The system (in Veraison) that checks evidence and produces results.  

### **Relying Party**
The consumer of the attestation result (e.g., a cloud service that decides access based on trust).  

---

## 🔹 Claims & Tokens

### **EAT (Entity Attestation Token)**
A token format (CBOR/COSE or JSON/JWT) for representing attestation evidence and results.  

### **Claims**
Individual pieces of information inside evidence or results (e.g., firmware version, boot measurements).  

---

## 🔹 Other Relevant Terms

### **Reference Values**
Known-good measurements or metadata used to evaluate evidence.  

### **Trust Anchor**
A root cryptographic key or certificate used as the foundation of trust.  

### **Endorser**
The entity (often a manufacturer) that provides endorsements and reference values.  

### **Verifier Plugin**
A pluggable module in Veraison that implements verification for a particular scheme.  

---
