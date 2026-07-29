<walkthrough>
# Network Lab Walkthrough — Student Demo

This walkthrough is written for students to apply the MikroTik learning script in a safe, staged manner.

Prerequisites
- A MikroTik RouterOS device (CCR/CRS/Cloud Router Switch or RB series) in lab with RouterOS v7+ recommended.
- A management workstation that can reach the device via Winbox, WebFig, or SSH.
- The repository files present on your workstation or transferred to the device (configs/mikrotik-hardened.rsc).

High-level steps
1. Clone the repo or download the config files to your workstation.
   git clone https://github.com/adahgodfrey-tech/Network-lab.git

2. Review the IP plan (docs/ip-plan.md) and map physical port names (etherX) to your hardware. Update configs/mikrotik-hardened.rsc accordingly.

3. Stage 0 — Backup current configuration
   - Use Winbox or SSH to connect and run:
     /export file=backup-before-apply
   - Download the backup file to your workstation for safekeeping (Files -> Download in Winbox or scp).

4. Stage 1 — Apply VLANs and SVIs only
   - Copy configs/mikrotik-hardened.rsc to the RouterOS device, or extract the VLAN/SVI sections and paste into the terminal.
   - Verify VLAN interfaces:
     /interface vlan print
   - Verify IP addresses:
     /ip address print

5. Stage 2 — Basic routing and allowed services
   - Import firewall rules that allow DHCP, DNS, HTTP/HTTPS from departments to servers. Do NOT import the final restrictive "drop all inter-department" rule yet.
   - Configure DHCP (either use the RouterOS DHCP examples or ensure relay to central DHCP server).

6. Stage 3 — Test connectivity
   - From a client in each VLAN, obtain a DHCP lease and confirm:
     - Correct gateway and DNS
     - Can reach servers in VLAN60 as allowed
     - Cannot reach other departments unless allowed

7. Stage 4 — Harden and finalize
   - Apply final ACLs/firewall rules to enforce isolation.
   - Create role-based user accounts for administration (admin, operator, readonly) per the hardened script.
   - Export a post-change backup:
     /export file=backup-after-apply

8. Rollback plan
   - If connectivity breaks and you need to revert, use the pre-change export file:
     /import file=backup-before-apply

Teaching tips
- Work incrementally: apply smaller sections of the script and test after each stage.
- Avoid applying scripts with a final "drop all" rule until you confirm allowed traffic.
- Encourage students to document the port->VLAN mapping and to use separate test hosts for each VLAN.

