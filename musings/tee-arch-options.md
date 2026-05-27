# Deploy with TEEs

## AWS Nitro prototype

* An "all-in-one-node" architecture, i.e., the scaling unit is the services conglomerate
* The intended split is:
  * TCB in _confidential_ VM (Nitro)
  * Non-TCB _normal_ VM (EC2)

```mermaid
flowchart LR
    SCA((supply</br>chain))
    ARP((attester</br>/ RP))
    subgraph EC2 Instance
    VFE
    PFE
    end
    ARP-- REST API ---VFE
    SCA-- REST API ---PFE
    VFE-- grpc/vsock ---VTS
    PFE-- grpc/vsock ---VTS
    subgraph Nitro Enclave
    VTS
    end
    VTS== ioctl ===NSM
    VTS-- kvstore ---DB[(Dynamo</br>/ RDS<br/>/ memory)]
```

### Observations

* Problem: the TCB _currently_ leaks into PFE: we need to move the whole CoRIM processor (both crypto verification and endorsements extraction) into VTS
  * Also, the tenant's bearer token presented to PFE MUST be bound to the CoRIM signer's key
* When generating the EAR signing key-pair on the fly (rather than pre-provisioning), the caching strategy that uses `.well-known/veraison` requires some form of session stickiness (e.g., API router needs dispatch based on the requester -- e.g., IP, bearer token, cookie).

## Alternative "all-in-one-node" architecture

* TCB and non-TCP in _confidential_ VM (Nitro)
* Transparent proxying function at the transport level in the _normal_ VM (EC2)

```mermaid
flowchart LR
    SCA((supply</br>chain))
    ARP((attester</br>/ RP))
    subgraph EC2 Instance
    tcp2vsock-pfe
    tcp2vsock-vfe
    end
    ARP-- REST API ---tcp2vsock-vfe
    SCA-- REST API ---tcp2vsock-pfe
    VFE-- grpc/localhost ---VTS
    PFE-- grpc/localhost ---VTS
    subgraph Nitro Enclave
    VFE
    PFE
    VTS
    end
    VTS== ioctl ===NSM
    VTS-- kvstore ---DB[(Dynamo</br>/ RDS<br/>/ memory)]
    tcp2vsock-vfe-- REST API/vsock ---VFE
    tcp2vsock-pfe-- REST API/vsock ---PFE
```

* All services are in the TCB, which is not great (obvious increase of attack surface)
* Only mods required:
  * REST FEs initialisation to use vsock
  * TCP to vsock proxy component[^1]
  
[^1]: There may be existing SW for this but I haven't investigated.  In any case it'd be a trivial piece of code.

## Disaggregated architectures

* All services are allocated to separate VMs
* API frontends (PFE and VFE) are hosted in normal EC2 instances
* VTS is hosted in a Nitro enclave with its parent EC2 instance running a vsock proxy
* An L3/L4 gRPC load balancer distributes the load among the available VTS
* Ideal when the load between provisioning and verification pipelines is asymmetric.  This is the expected case.

```mermaid
flowchart LR
    SCA((supply</br>chain))
    ARP-1((attester</br>/ RP))
    ARP-2((attester</br>/ RP))
    subgraph p1 [EC2 Instance]
    PFE-1[PFE]
    end
    subgraph v1 [EC2 Instance]
    VFE-1[VFE]
    end
    subgraph v2 [EC2 Instance]
    VFE-2[VFE]
    end
    subgraph grpclb [gRPC LB]
    gRPC-LB
    end
    SCA-- REST ---PFE-1
    ARP-1-- REST ---VFE-1
    ARP-2-- REST ---VFE-2
    PFE-1-- gRPC ---gRPC-LB
    VFE-1-- gRPC ---gRPC-LB
    VFE-2-- gRPC ---gRPC-LB
    subgraph vtsfe1 [EC2 Instance]
    tcp2vsock-vts-1[vsock-proxy]
    end
    subgraph vtsfe2 [EC2 Instance]
    tcp2vsock-vts-2[vsock-proxy]
    end
    subgraph vtsbe1 [Nitro Enclave]
    VTS-1[VTS]
    end
    subgraph vtsbe2 [Nitro Enclave]
    VTS-2[VTS]
    end
    subgraph vts2 [ ]
    vtsfe2
    vtsbe2
    end
    subgraph vts1 [ ]
    vtsfe1
    vtsbe1
    end
    gRPC-LB-- gRPC ---tcp2vsock-vts-1
    gRPC-LB-- gRPC ---tcp2vsock-vts-2
    tcp2vsock-vts-1-- gRPC/vsock ---VTS-1
    tcp2vsock-vts-2-- gRPC/vsock ---VTS-2
    VTS-1-- kvstore ---DB[(Dynamo</br>/ RDS<br/>/ memory)]
    VTS-1== ioctl ===NSM-1[NSM]
    VTS-2-- kvstore ---DB[(Dynamo</br>/ RDS<br/>/ memory)]
    VTS-2== ioctl ===NSM-2[NSM]
```
