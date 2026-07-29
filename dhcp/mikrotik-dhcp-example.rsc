# MikroTik DHCP server example (per VLAN interface)
# Run these commands on RouterOS after creating the vlanX interfaces and assigning the SVI IPs.

# Example for Computer Science (vlan30)
/ip dhcp-server
add name=dhcp-vlan30 interface=vlan30 lease-time=7d address-pool=pool-vlan30 disabled=no

/ip pool
add name=pool-vlan30 ranges=10.10.24.10-10.10.27.254

/ip dhcp-server network
add address=10.10.24.0/22 gateway=10.10.24.1 dns-server=10.10.31.10,8.8.8.8 domain=polytechnic.local

# Repeat for other VLANs (examples)
# BUSINESS (vlan10)
add name=dhcp-vlan10 interface=vlan10 lease-time=7d address-pool=pool-vlan10 disabled=no
add name=pool-vlan10 ranges=10.10.0.10-10.10.15.254
add address=10.10.0.0/20 gateway=10.10.0.1 dns-server=10.10.31.10,8.8.8.8

# FINE_ART (vlan50)
add name=dhcp-vlan50 interface=vlan50 lease-time=7d address-pool=pool-vlan50 disabled=no
add name=pool-vlan50 ranges=10.10.30.10-10.10.30.250
add address=10.10.30.0/24 gateway=10.10.30.1 dns-server=10.10.31.10

# Adjust and repeat for all VLANs. For production use, consider a central DHCP server and use DHCP relay

