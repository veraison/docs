# Veraison Terminology

This document explains the key concepts and terms used in **Project Veraison**.  
It is intended to help new contributors, developers, and users quickly understand the terminology.

---

## 🔹 Provisioning

### **CoRIM (Concise Reference Integrity Manifest)**
A data format that provides trusted Reference Values (baselines) and Endorsements for remote attestation.  
It defines what are "golden values" for a platform or component.  
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
A verification policy or method supported by Veraison that defines how Evidence should be interpreted and matched against Reference Values.  

### **Verifier**
The entity that validates Evidence against Endorsements and Reference Values to produce an Attestation Result.  

### **Attestation Result**
The outcome of the verification process, usually expressing whether the evidence is trustworthy.  

---

## 🔹 Attestation Roles (from IETF RATS)

### **Attester**
The device or system that generates Evidence about its state.  

### **Verifier**
An entity (typically a collection of components in Veraison) that  appraise Evidence and produces Attestation Results.  

### **Relying Party**
The consumer of the Attestation Result (e.g., a cloud service that decides access based on trust).  

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
