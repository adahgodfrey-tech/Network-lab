# MikroTik RouterOS Template (RouterOS v7+ style, lab/learning script)

# WARNING: Test and adapt to your hardware and RouterOS version before applying.
# This script demonstrates the following:
# - Create a bridge for local switch ports
# - Enable VLAN filtering and create VLAN interfaces (L3 SVIs)
# - Assign IP addresses to VLAN interfaces (the "SVI" role)
# - Configure trunk (uplink) port and sample access-port configuration
# - Notes about QoS, DHCP, and security features (DHCP snooping equivalent is limited on RouterOS)

# --- Basic bridge and ports setup -------------------------------------------------
/interface bridge
add name=bridge-local vlan-filtering=yes comment="Local access bridge (VLAN filtering enabled)"

# Add physical ports to the bridge (example: ether2-ether10 are access ports; ether1 is uplink/trunk)
/interface bridge port
add bridge=bridge-local interface=ether1 comment="Uplink/trunk to core/router"
# Example access ports for Computer Science (change ranges to match hardware)
add bridge=bridge-local interface=ether2 pvid=30 comment="CS access port example"
add bridge=bridge-local interface=ether3 pvid=30
add bridge=bridge-local interface=ether4 pvid=50 comment="Fine Art example"
add bridge=bridge-local interface=ether5 pvid=20 comment="Marketing example"
# Add more ports as needed in your lab

# --- VLAN definitions on the bridge ------------------------------------------------
# Define which ports are tagged/untagged for each VLAN
/interface bridge vlan
add bridge=bridge-local tagged=ether1 untagged=ether2,ether3 vlan-ids=30  comment="Computer Science"
add bridge=bridge-local tagged=ether1 untagged=ether5 vlan-ids=20  comment="Marketing"
add bridge=bridge-local tagged=ether1 untagged=ether4 vlan-ids=50  comment="Fine Art"
add bridge=bridge-local tagged=ether1 vlan-ids=10,40,60,70,80,90,99 comment="Other VLANs tagged on trunk"

# --- Create VLAN interfaces (SVI equivalents) -------------------------------------
# Create VLAN interfaces attached to the bridge (RouterOS will handle tag/untagging)
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

# --- Assign IP addresses to the VLAN interfaces (SVIs) ------------------------------
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

# --- Enable IP routing / default route (example) ----------------------------------
# If this RouterOS device is the gateway to the internet, add a default route via your ISP/gateway.
# Example: replace x.x.x.x with the upstream gateway on ether1 (if present)
#/ip route add dst-address=0.0.0.0/0 gateway=x.x.x.x

# --- DHCP server (optional on RouterOS) -----------------------------------------
# RouterOS can serve DHCP per VLAN interface — examples are provided in dhcp/mikrotik-dhcp-example.rsc

# --- Example firewall rules / basic inter-VLAN policy ----------------------------
# Best practice: default deny between departments; allow only required traffic to servers.
# Simple example: drop traffic from guest (vlan90) to internal networks
/ip firewall filter
add chain=forward in-interface=vlan90 action=drop comment="Block Guest -> internal"
# Allow established/related
add chain=forward connection-state=established,related action=accept comment="Allow established"

# Allow departments to reach servers (HTTP/HTTPS example) - adapt to your needs
add chain=forward in-interface=vlan30 dst-address=10.10.31.0/24 protocol=tcp dst-port=80,443 action=accept comment="CS -> Servers HTTP/HTTPS"
add chain=forward in-interface=vlan20 dst-address=10.10.31.0/24 protocol=tcp dst-port=80,443 action=accept comment="Marketing -> Servers HTTP/HTTPS"

# Finally, drop other inter-department traffic (be careful while applying)
add chain=forward action=drop comment="Drop all other inter-department traffic (apply after specific allows)"

# --- QoS / VoIP considerations ---------------------------------------------------
# Mark DSCP for DSCP-aware phones or trust DSCP from phones. Example shows a simple mangle rule
#/ip firewall mangle
# add chain=prerouting in-interface=vlan80 action=mark-packet new-packet-mark=voice passthrough=yes comment="Mark voice packets"

# --- Notes: security features ----------------------------------------------------
# RouterOS does not implement DHCP snooping/DAI in the same manner as enterprise switches; ensure port security and strict ACLs.
# Use switch chip features on CCR/Cloud Router Switch models for hardware VLANs and port isolation where available.

# End of template
