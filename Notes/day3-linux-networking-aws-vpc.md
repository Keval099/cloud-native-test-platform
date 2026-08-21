# Day 3 — Linux Networking & AWS VPC Foundations

## Overview

Day 3 focused on understanding networking from the Linux level and mapping those concepts into the AWS architecture for the Cloud-Native Test Platform.

```text
Linux networking
    ↓
IP addresses
    ↓
Routing
    ↓
DNS
    ↓
TCP / UDP
    ↓
Ports and sockets
    ↓
Processes and listening services
    ↓
HTTP / curl
    ↓
TCP connection lifecycle
    ↓
AWS VPC
    ↓
Subnets
    ↓
Route tables
    ↓
Internet Gateway
    ↓
Security Groups
    ↓
ALB → EKS → RDS
```

---

## 1. Linux Network Interfaces

### `ip addr`

```bash
ip addr
```

Used to inspect network interfaces and their IP addresses.

Observed in WSL:

```text
lo
    127.0.0.1/8
    10.255.255.254/32

eth0
    172.26.67.222/20
```

`127.0.0.1` is the loopback address and represents the local machine.

---

## 2. CIDR and IPv4

CIDR examples:

```text
10.0.0.0/16
10.0.1.0/24
10.0.11.0/28
```

For IPv4:

```text
Total addresses = 2^(32 - prefix)
```

Examples:

```text
/16 → 2^16 = 65,536
/24 → 2^8  = 256
/28 → 2^4  = 16
```

A `/16` can be divided into:

```text
65,536 / 256 = 256
```

separate `/24` networks.

Example:

```text
10.0.0.0/16
│
├── 10.0.0.0/24
├── 10.0.1.0/24
├── 10.0.2.0/24
└── ...
```

---

## 3. Linux Routing

### `ip route`

```bash
ip route
```

Observed:

```text
default via 172.26.64.1 dev eth0
172.26.64.0/20 dev eth0 proto kernel scope link src 172.26.67.222
```

The default route is used when a destination does not match a more specific route.

General process:

```text
Destination
    ↓
Route lookup
    ↓
Matching route
    ↓
Next hop / interface
```

---

## 4. Connectivity Testing

### Loopback

```bash
ping -c 4 127.0.0.1
```

This succeeded with 0% packet loss.

### Internet

```bash
ping -c 4 8.8.8.8
```

This succeeded and demonstrated Internet connectivity from WSL.

A failed ping does not automatically prove that the network path is broken because ICMP may be blocked or ignored.

---

## 5. DNS

### Resolve a hostname

```bash
getent hosts google.com
```

### Inspect resolver configuration

```bash
cat /etc/resolv.conf
```

Observed:

```text
nameserver 10.255.255.254
```

Important distinction:

```text
DNS
→ resolves names to IP addresses

Routing
→ determines how traffic reaches an IP
```

---

## 6. TCP vs UDP

### TCP

TCP is connection-oriented and uses connection states such as:

```text
LISTEN
ESTABLISHED
CLOSED
```

### UDP

UDP is connectionless and does not establish a TCP-style connection before sending data.

---

## 7. Ports and Sockets

### `ss`

```bash
ss -tuln
```

Useful options:

```text
-t  TCP
-u  UDP
-l  listening
-n  numeric output
```

Example:

```text
tcp LISTEN 0 5 127.0.0.1:8080 0.0.0.0:*
```

This means a TCP service is listening on:

```text
127.0.0.1:8080
```

---

## 8. Process ↔ Port

We ran:

```bash
ss -tulpn | grep 8080
```

and identified the process:

```text
python3
```

Then:

```bash
ps -p 3118 -f
```

showed:

```text
python3 -m http.server 8080 --bind 127.0.0.1
```

The troubleshooting relationship is:

```text
Process
   ↓
Socket
   ↓
IP:Port
   ↓
Listening service
```

---

## 9. Local HTTP Server

We used:

```bash
python3 -m http.server 8080 --bind 127.0.0.1
```

Then:

```bash
curl http://127.0.0.1:8080
```

The server returned an HTTP directory listing.

The basic flow:

```text
curl
  ↓
TCP connection
  ↓
HTTP GET /
  ↓
Python HTTP server
  ↓
HTTP response
```

We also tested binding to:

```text
0.0.0.0:8080
```

`127.0.0.1` means loopback only, while `0.0.0.0` means listening on all IPv4 interfaces.

---

## 10. TCP Connection States

Useful commands:

```bash
ss -tn
ss -tn state listening
ss -tn state established
```

A short HTTP connection can establish and close so quickly that `ss` may not catch it in the `ESTABLISHED` state.

That does not mean the TCP connection never existed.

---

## 11. TCP Three-Way Handshake

Simplified:

```text
Client                         Server
  |                              |
  | -------- SYN --------------> |
  | <------ SYN-ACK ------------ |
  | -------- ACK --------------> |
  |                              |
  |====== ESTABLISHED ===========|
```

Then application data can be exchanged.

For HTTP:

```text
TCP connection
      ↓
HTTP request
      ↓
HTTP response
```

---

## 12. TCP Return Traffic and Ephemeral Ports

Example request:

```text
ALB:49152 → App:8080
```

Return traffic:

```text
App:8080 → ALB:49152
```

Another example:

```text
App:52000 → RDS:5432
```

Return:

```text
RDS:5432 → App:52000
```

The exact ephemeral port is dynamically selected.

The important concept is:

> The original client source port becomes the destination port for return traffic.

This becomes important when understanding stateless NACLs.

---

## 13. Connection Refused

We tested:

```bash
curl -v http://127.0.0.1:9999
```

while nothing was listening on port 9999.

Then:

```bash
ss -tuln | grep 9999
```

returned nothing.

The result was:

```text
Connection refused
```

Troubleshooting:

```text
curl
  ↓
127.0.0.1:9999
  ↓
No listener
  ↓
Connection refused
```

A timeout can indicate a different class of issue such as filtering, routing, or a non-responsive path.

---

# 14. AWS VPC

Created:

```text
cloud-native-test-platform-vpc
10.0.0.0/16
```

The VPC provides the overall private IPv4 address space for the project.

---

# 15. Availability Zones

The design uses:

```text
ap-south-1a
ap-south-1b
```

Logical structure:

```text
VPC
│
├── AZ-A
│   ├── Public
│   ├── App
│   └── DB
│
└── AZ-B
    ├── Public
    ├── App
    └── DB
```

This provides a foundation for high availability.

---

# 16. Subnet Design

## Public

```text
cloud-native-public-a
10.0.1.0/24
ap-south-1a

cloud-native-public-b
10.0.2.0/24
ap-south-1b
```

Intended for the internet-facing ALB.

## Application

```text
cloud-native-app-a
10.0.11.0/24
ap-south-1a

cloud-native-app-b
10.0.12.0/24
ap-south-1b
```

Intended for EKS/application workloads.

## Database

```text
cloud-native-db-a
10.0.21.0/24
ap-south-1a

cloud-native-db-b
10.0.22.0/24
ap-south-1b
```

Intended for RDS PostgreSQL.

---

# 17. Internet Gateway

Created:

```text
cloud-native-igw
```

and attached it to the VPC.

Important:

> Attaching an Internet Gateway to a VPC does not automatically make every subnet public.

A subnet needs a route toward the Internet Gateway.

---

# 18. Public Route Table

Created:

```text
cloud-native-public-rt
```

Routes:

```text
Destination       Target
-------------------------
10.0.0.0/16       local
0.0.0.0/0         Internet Gateway
```

Associated with:

```text
cloud-native-public-a
cloud-native-public-b
```

Therefore these are the public subnets.

---

# 19. Private Application Route Table

Created:

```text
cloud-native-app-rt
```

Route:

```text
10.0.0.0/16 → local
```

Associated with:

```text
cloud-native-app-a
cloud-native-app-b
```

There is currently no Internet Gateway route and no NAT Gateway.

---

# 20. Private Database Route Table

Created:

```text
cloud-native-db-rt
```

Route:

```text
10.0.0.0/16 → local
```

Associated with:

```text
cloud-native-db-a
cloud-native-db-b
```

There is no direct Internet Gateway route.

---

# 21. Public vs Private Subnet

A subnet is considered public when its associated route table has a route to an Internet Gateway.

Example:

```text
0.0.0.0/0 → Internet Gateway
```

A private subnet does not have a direct Internet Gateway route.

---

# 22. NAT Gateway

We intentionally did not create a NAT Gateway.

A NAT Gateway can provide outbound Internet access for private-subnet resources:

```text
Private EKS
    ↓
Private Route Table
    ↓
0.0.0.0/0 → NAT Gateway
    ↓
Internet Gateway
    ↓
Internet
```

NAT does not make private resources directly reachable from the Internet.

We postponed it because NAT Gateways are billable resources and we do not currently need one for the networking foundation.

---

# 23. Security Groups

Three Security Groups were created.

## ALB SG

```text
cloud-native-alb-sg
```

Inbound:

```text
TCP 443
Source: 0.0.0.0/0
```

Purpose:

```text
Internet → ALB :443
```

## Application SG

```text
cloud-native-app-sg
```

Inbound:

```text
TCP 8080
Source: cloud-native-alb-sg
```

Purpose:

```text
ALB-SG → App-SG :8080
```

The application is not directly exposed with:

```text
0.0.0.0/0 → 8080
```

## RDS SG

```text
cloud-native-rds-sg
```

Inbound:

```text
TCP 5432
Source: cloud-native-app-sg
```

Purpose:

```text
App-SG → RDS-SG :5432
```

PostgreSQL is not directly exposed to the Internet.

---

# 24. Security Groups vs NACLs

## Security Group

```text
Resource/network-interface level
Stateful
Allow rules
```

Example:

```text
ALB-SG → App-SG :8080
App-SG → RDS-SG :5432
```

Return traffic for an allowed connection is automatically handled because Security Groups are stateful.

## NACL

```text
Subnet level
Stateless
Allow and deny rules
```

NACLs require both directions of traffic to be considered.

Example:

```text
ALB:49152 → App:8080
App:8080 → ALB:49152
```

---

# 25. Why Custom NACLs Were Skipped

Custom NACLs are not strictly required for this project.

We decided to keep the default NACL rather than introduce unnecessary complexity.

The main security boundary for the application will be the Security Groups.

NACL knowledge remains important for AWS networking and SAA understanding.

---

# 26. Route Table vs Security Group

This is one of the most important Day 3 concepts.

### Route Table

Answers:

> Where can the traffic go?

Example:

```text
0.0.0.0/0 → Internet Gateway
```

### Security Group

Answers:

> Is this traffic allowed to reach the resource?

Example:

```text
ALB-SG → TCP 8080 → App
```

Important:

> A Security Group does not create a route.

> A route table does not grant application access permission.

Both can be required.

---

# 27. Project Traffic Flow

## Internet → ALB

```text
Internet
   ↓ TCP 443
Internet Gateway
   ↓
Public Route Table
   ↓
Public Subnet
   ↓
ALB
   ↓
ALB-SG allows 443
```

## ALB → EKS

```text
ALB
   ↓ TCP 8080
App subnet
   ↓
10.0.0.0/16 → local
   ↓
EKS
   ↓
App-SG allows traffic from ALB-SG
```

## EKS → RDS

```text
EKS
   ↓ TCP 5432
DB subnet
   ↓
10.0.0.0/16 → local
   ↓
RDS
   ↓
RDS-SG allows traffic from App-SG
```

---

# 28. Traffic That Should Fail

## Internet → EKS :8080

Should fail because:

- EKS is in a private subnet.
- No direct IGW route exists.
- App-SG only permits traffic from ALB-SG.

## Internet → RDS :5432

Should fail because:

- RDS is in private DB subnets.
- No direct Internet route exists.
- RDS-SG only permits traffic from App-SG.

## RDS → Internet

Currently fails because the DB route table has no external route.

## EKS → Internet

Currently fails because the App route table has no `0.0.0.0/0` route to a NAT Gateway.

---

# 29. Day 3 Troubleshooting Model

When a connection fails, check in this general order:

```text
DNS resolution?
      ↓
Correct IP?
      ↓
Correct route?
      ↓
Correct port?
      ↓
Is something listening?
      ↓
Security Group?
      ↓
NACL, if applicable?
      ↓
TCP connection?
      ↓
Application protocol?
```

Useful Linux commands:

```bash
ip addr
ip route
ping
getent hosts
cat /etc/resolv.conf
ss -tuln
ss -tn
ps
curl
```

---

# 30. Final Architecture

```text
                         INTERNET
                             |
                             | TCP 443
                             v
                    +----------------+
                    |      ALB       |
                    |    ALB-SG      |
                    +-------+--------+
                            |
                            | TCP 8080
                            v
                    +----------------+
                    |      EKS       |
                    |   Spring Boot  |
                    |    App-SG      |
                    +-------+--------+
                            |
                            | TCP 5432
                            v
                    +----------------+
                    |      RDS       |
                    |   PostgreSQL   |
                    |    RDS-SG      |
                    +----------------+
```

Network:

```text
VPC 10.0.0.0/16
│
├── AZ-A
│   ├── Public-A  10.0.1.0/24
│   ├── App-A     10.0.11.0/24
│   └── DB-A      10.0.21.0/24
│
└── AZ-B
    ├── Public-B  10.0.2.0/24
    ├── App-B     10.0.12.0/24
    └── DB-B      10.0.22.0/24
```

---

# 31. Day 3 AWS Resources

Created:

```text
VPC
    cloud-native-test-platform-vpc

Internet Gateway
    cloud-native-igw

Route Tables
    cloud-native-public-rt
    cloud-native-app-rt
    cloud-native-db-rt

Security Groups
    cloud-native-alb-sg
    cloud-native-app-sg
    cloud-native-rds-sg
```

Subnets:

```text
cloud-native-public-a  10.0.1.0/24
cloud-native-public-b  10.0.2.0/24

cloud-native-app-a     10.0.11.0/24
cloud-native-app-b     10.0.12.0/24

cloud-native-db-a      10.0.21.0/24
cloud-native-db-b      10.0.22.0/24
```

---

# 32. Resources Deliberately Not Created

```text
NAT Gateway
ALB
EKS
EC2 worker nodes
RDS
Prometheus
Grafana
```

These will be introduced later when needed.

---

# 33. Day 3 Cost Awareness

The networking foundation was intentionally built without the major hourly-cost resources.

Created:

```text
VPC
Subnets
Route Tables
Internet Gateway
Security Groups
```

Major billable resources postponed:

```text
NAT Gateway
EKS
EC2
ALB
RDS
```

Always verify current AWS pricing before creating chargeable resources.

---

# 34. Day 3 Completion Checklist

- [x] Understand Linux network interfaces
- [x] Understand IPv4 CIDR notation
- [x] Calculate `/16`, `/24`, `/28`
- [x] Understand Linux routing
- [x] Test loopback
- [x] Test Internet connectivity
- [x] Understand DNS
- [x] Understand TCP vs UDP
- [x] Inspect ports with `ss`
- [x] Map ports to processes
- [x] Run a local HTTP server
- [x] Test HTTP with `curl`
- [x] Understand LISTEN and ESTABLISHED
- [x] Understand TCP three-way handshake
- [x] Understand ephemeral ports
- [x] Troubleshoot connection refused
- [x] Create AWS VPC
- [x] Create six subnets
- [x] Use two Availability Zones
- [x] Create and attach Internet Gateway
- [x] Create public route table
- [x] Create private App route table
- [x] Create private DB route table
- [x] Associate subnets correctly
- [x] Create ALB Security Group
- [x] Create App Security Group
- [x] Create RDS Security Group
- [x] Understand Security Groups vs NACLs
- [x] Decide to retain the default NACL
- [x] Understand ALB → EKS → RDS traffic
- [x] Understand routing vs security permissions
- [x] Avoid major billable infrastructure during the networking foundation

---

# Day 3 Final Mental Model

When troubleshooting a network connection, ask:

```text
WHO?
  ↓
Security Group

WHERE?
  ↓
Route Table

WHICH SUBNET?
  ↓
Subnet / NACL

WHICH IP?
  ↓
Destination

WHICH PORT?
  ↓
TCP / UDP

IS ANYTHING LISTENING?
  ↓
Process / Socket

WHAT APPLICATION PROTOCOL?
  ↓
HTTP / PostgreSQL / etc.
```

## Core principle

> **Routing determines where traffic can go. Security controls determine whether traffic is allowed. The application must still be listening on the destination port.**

---

## Next Day

Day 4 will move into the application/container layer:

```text
Spring Boot
    ↓
Docker
    ↓
Dockerfile
    ↓
Local container
    ↓
ECR
    ↓
EKS
```

The goal is to build and test the application locally before introducing the cloud deployment layer.
