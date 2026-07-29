# MikroTik hardened script with role-based management, backup/export, and staged-apply guidance

# NOTE: Review and adapt policies and usernames before applying. Test in lab first.

# Backup current config
/export file=backup-before-hardened-$(/system clock get time | :put)

# --- Create admin/operator/readonly user groups and accounts ----------------------------------
# RouterOS user policy strings differ by version; adjust the 'policy' lists to your RouterOS version.
# Example groups (verify exact policy names on your device):
# - full-admin: full privileges
# - operator: limited to configuration and monitoring
# - readonly: read-only access

/user group
add name=full-admin policy=ftp,reboot,read,write,policy,test,winbox,password,sniff,sensitive comment="Full administrator group"
add name=operator policy=read,write,policy,test,winbox comment="Operator group with config privileges"
add name=readonly policy=read comment="Read-only group for observers"

# Add users (change passwords immediately)
/user
add name=lab-admin group=full-admin password="ChangeMeNow!" comment="Full admin account - change password"
add name=lab-operator group=operator password="OperatorPwd" comment="Operator account - limited"
add name=lab-readonly group=readonly password="ReadOnlyPwd" comment="Read-only account for students"

# --- Staged apply instructions (manual gating recommended) ---------------------------------
# The script is organized into sections. To avoid locking yourself out, apply sections one at a time.
# Section markers (search in the file):
# === SECTION: VLANS ===
# === SECTION: SVIS ===
# === SECTION: DHCP ===
# === SECTION: FIREWALL ===
# === SECTION: FINAL_HARDEN ===

# === SECTION: VLANS ===
/interface bridge
add name=bridge-local vlan-filtering=yes comment="Local access bridge (VLAN filtering enabled)"
/interface bridge port
add bridge=bridge-local interface=ether1 comment="Uplink/trunk to core/router"
add bridge=bridge-local interface=ether2 pvid=30 comment="CS access port"
add bridge=bridge-local interface=ether3 pvid=30
add bridge=bridge-local interface=ether4 pvid=50 comment="Fine Art"
add bridge=bridge-local interface=ether5 pvid=20 comment="Marketing"

/interface bridge vlan
add bridge=bridge-local tagged=ether1 untagged=ether2,ether3 vlan-ids=30  comment="Computer Science"
add bridge=bridge-local tagged=ether1 untagged=ether5 vlan-ids=20  comment="Marketing"
add bridge=bridge-local tagged=ether1 untagged=ether4 vlan-ids=50  comment="Fine Art"
add bridge=bridge-local tagged=ether1 vlan-ids=10,40,60,70,80,90,99 comment="Other VLANs tagged on trunk"

# === SECTION: SVIS ===
/interface vlan
add name=vlan10 vlan-id=10 interface=bridge-local
add name=vlan20 vlan-id=20 interface=bridge-local
add name=vlan30 vlan-id=30 interface=bridge-local
add name=vlan40 vlan-id=40 interface=bridge-local
add name=vlan50 vlan-id=50 interface=bridge-local
add name=vlan60 vlan-id=60 interface=bridge-local
add name=vlan70 vlan-id=70 interface=bridge-local
add name=vlan80 vlan-id=80 interface=bridge-local
add name=vlan90 vlan-id=90 interface=bridge-local
add name=vlan99 vlan-id=99 interface=bridge-local

/ip address
add address=10.10.0.1/20 interface=vlan10 comment="BUSINESS SVI"
add address=10.10.16.1/21 interface=vlan20 comment="MARKETING SVI"
add address=10.10.24.1/22 interface=vlan30 comment="COMPUTER_SCIENCE SVI"
add address=10.10.28.1/23 interface=vlan40 comment="ELECTRICAL SVI"
add address=10.10.30.1/24 interface=vlan50 comment="FINE_ART SVI"
add address=10.10.31.1/24 interface=vlan60 comment="SERVERS SVI"
add address=10.10.32.1/26 interface=vlan70 comment="PRINTERS SVI"
add address=10.10.32.65/26 interface=vlan80 comment="VOIP SVI"
add address=10.10.32.129/25 interface=vlan90 comment="WIFI_GUEST SVI"
add address=10.10.33.1/29 interface=vlan99 comment="MGMT SVI"

# After applying VLANS and SVIs: verify /interface vlan print and /ip address print

# === SECTION: DHCP ===
# Configure RouterOS DHCP servers if you are using the device to serve DHCP in the lab.
/ip pool
add name=pool-vlan30 ranges=10.10.24.10-10.10.27.254
add name=pool-vlan10 ranges=10.10.0.10-10.10.15.254
add name=pool-vlan50 ranges=10.10.30.10-10.10.30.250
add name=pool-vlan31 ranges=10.10.31.100-10.10.31.200

/ip dhcp-server
add name=dhcp-vlan30 interface=vlan30 lease-time=7d address-pool=pool-vlan30 disabled=no
add name=dhcp-vlan10 interface=vlan10 lease-time=7d address-pool=pool-vlan10 disabled=no
add name=dhcp-vlan50 interface=vlan50 lease-time=7d address-pool=pool-vlan50 disabled=no
add name=dhcp-vlan60 interface=vlan60 lease-time=7d address-pool=pool-vlan31 disabled=no

/ip dhcp-server network
add address=10.10.24.0/22 gateway=10.10.24.1 dns-server=10.10.31.10,8.8.8.8 domain=polytechnic.local
add address=10.10.0.0/20 gateway=10.10.0.1 dns-server=10.10.31.10,8.8.8.8
add address=10.10.30.0/24 gateway=10.10.30.1 dns-server=10.10.31.10
add address=10.10.31.0/24 gateway=10.10.31.1 dns-server=10.10.31.10

# === SECTION: FIREWALL ===
# Base allow rules for DHCP and established connections
/ip firewall filter
add chain=forward connection-state=established,related action=accept comment="Allow established"
add chain=forward protocol=udp dst-port=67-68 action=accept comment="Allow DHCP relay/server"
add chain=forward protocol=udp dst-port=53 action=accept comment="Allow DNS"

# Allow departments to access servers on HTTP/HTTPS as example
add chain=forward in-interface=vlan30 dst-address=10.10.31.0/24 protocol=tcp dst-port=80,443 action=accept comment="CS -> Servers HTTP/HTTPS"
add chain=forward in-interface=vlan20 dst-address=10.10.31.0/24 protocol=tcp dst-port=80,443 action=accept comment="Marketing -> Servers HTTP/HTTPS"

# Prevent guest from reaching internal networks
add chain=forward in-interface=vlan90 action=drop comment="Block Guest -> internal"

# Final restrictive rule is intentionally commented out for staged apply — enable after testing
# add chain=forward action=drop comment="Drop all other inter-department traffic (enable after testing)"

# === SECTION: FINAL_HARDEN (manual steps) ===
# - Review firewall rules and enable the final drop rule only after testing
# - Remove default 'admin' user or change its password
# - Configure secure management (disable telnet, enable SSH only, restrict Winbox by source IP)
# Example:
/ip service
set telnet disabled=yes
set ftp disabled=yes
set www disabled=yes
set api disabled=yes
set ssh port=22

# Export a post-change backup (manual run recommended)
/export file=backup-after-hardened

# End of hardened script
