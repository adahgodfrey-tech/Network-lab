# IP Plan — VLANs, Subnets and DHCP ranges

This document lists the VLANs used in the Network Lab, their subnet allocations (unique masks), gateways (SVI addresses), and suggested DHCP ranges.

Campus base: 10.10.0.0/16 (private IP space)

Department VLANs (unique subnet masks)

- VLAN 10 — BUSINESS
  - Subnet: 10.10.0.0/20
  - Mask: 255.255.240.0
  - Usable hosts: 4094
  - Gateway (SVI): 10.10.0.1
  - DHCP pool suggestion: 10.10.0.10 - 10.10.15.254

- VLAN 20 — MARKETING
  - Subnet: 10.10.16.0/21
  - Mask: 255.255.248.0
  - Usable hosts: 2046
  - Gateway: 10.10.16.1
  - DHCP pool suggestion: 10.10.16.10 - 10.10.23.254

- VLAN 30 — COMPUTER_SCIENCE
  - Subnet: 10.10.24.0/22
  - Mask: 255.255.252.0
  - Usable hosts: 1022
  - Gateway: 10.10.24.1
  - DHCP pool suggestion: 10.10.24.10 - 10.10.27.254

- VLAN 40 — ELECTRICAL
  - Subnet: 10.10.28.0/23
  - Mask: 255.255.254.0
  - Usable hosts: 510
  - Gateway: 10.10.28.1
  - DHCP pool suggestion: 10.10.28.10 - 10.10.29.254

- VLAN 50 — FINE_ART
  - Subnet: 10.10.30.0/24
  - Mask: 255.255.255.0
  - Usable hosts: 254
  - Gateway: 10.10.30.1
  - DHCP pool suggestion: 10.10.30.10 - 10.10.30.250

Service VLANs (L3 switch)

- VLAN 60 — SERVERS
  - Subnet: 10.10.31.0/24
  - Gateway: 10.10.31.1
  - Notes: Reserve low addresses for domain controllers, DNS, DHCP, and other shared services (e.g., .10-.50 static)

- VLAN 70 — PRINTERS
  - Subnet: 10.10.32.0/26
  - Mask: 255.255.255.192
  - Usable hosts: 62
  - Gateway: 10.10.32.1

- VLAN 80 — VOIP
  - Subnet: 10.10.32.64/26
  - Gateway: 10.10.32.65
  - Notes: Mark DSCP for voice, use voice VLAN on access ports for phones

- VLAN 90 — WIFI_GUEST
  - Subnet: 10.10.32.128/25
  - Gateway: 10.10.32.129
  - Usable hosts: 126
  - Notes: Internet only; block access to internal VLANs

- VLAN 99 — MANAGEMENT
  - Subnet: 10.10.33.0/29
  - Mask: 255.255.255.248
  - Usable hosts: 6
  - Gateway: 10.10.33.1
  - Notes: Reserve for switch/router management IPs, out-of-band consoles, and monitoring hosts

Design notes
- Each department uses a unique subnet mask per the original constraint. The masks chosen are intentionally larger than the current host counts to provide growth margin.
- Keep clear documentation mapping switch ports to VLANs and maintain a CSV or YAML record for allocations.
- Shared servers should live in VLAN 60. Apply ACLs to permit only required traffic from each department to specific server ports.

DHCP guidelines
- Reserve the SVI (.1) and static server addresses (.2-.50) via DHCP exclusions or by using static reservations.
- Use a central DHCP server (recommended) or RouterOS DHCP per VLAN (examples in /dhcp).
- Example DHCP exclusions:
  - Exclude 10.10.24.1-10.10.24.10 on Computer Science subnet for gateways/servers

Implementation checklist (short)
1. Create management VLAN (99) and secure switch access (SSH, RBAC/TACACS or local AAA)
2. Create VLANs and SVI IPs on the L3 switch (see configs/mikrotik-switch-template.rsc)
3. Configure trunk ports between switches and to the core/router; allow the VLAN list
4. Configure DHCP (central server preferred). Ensure relay/bootp if using external DHCP
5. Configure ACLs: default deny between departments, allow specific services to VLAN60
6. Enable security features: DHCP snooping/DAI (if supported), port-security, BPDU-guard
7. Test connectivity and document results

