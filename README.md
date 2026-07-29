# Network Lab - VLAN & IP Plan (MikroTik)

This repository contains a learning-ready VLAN and IP addressing plan for a polytechnic campus network, plus example configurations for a MikroTik L3 switch/router and DHCP server examples. The plan uses unique subnet masks for each department (as requested) and provides additional service VLANs (servers, printers, VoIP, Wi‑Fi Guest, management).

Files included
- docs/ip-plan.md — VLAN table, subnets, masks, gateways, and DHCP ranges
- configs/mikrotik-switch-template.rsc — RouterOS (MikroTik) script template for VLAN interfaces (SVIs), trunk/access examples, and basic security/QoS notes
- dhcp/isc-dhcpd.conf.example — Example ISC DHCP server config with pools for each VLAN
- dhcp/mikrotik-dhcp-example.rsc — MikroTik RouterOS DHCP server example commands

How to use this repository
1. Read docs/ip-plan.md to understand the VLAN IDs, subnets, gateway IPs, and DHCP ranges.
2. Review the MikroTik script in configs/mikrotik-switch-template.rsc and adapt interface names and port mappings to your hardware. This script is a teaching template — test in a lab before production.
3. If you prefer a central DHCP server, adapt dhcp/isc-dhcpd.conf.example and run it on an ISC DHCP server (Linux). If you want RouterOS to provide DHCP, use dhcp/mikrotik-dhcp-example.rsc.
4. Follow the Implementation checklist in docs/ip-plan.md for a safe rollout.

Notes and disclaimers
- These examples are written for learning and lab use. Carefully review and adapt security, ACLs, and port assignments before production.
- The MikroTik RouterOS syntax varies between v6 and v7; comments indicate where adjustments may be needed.

