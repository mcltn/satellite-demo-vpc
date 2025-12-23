resource "ibm_is_vpc" "sat-vpc" {
  name = "${local.PREFIX}-${var.vpc_name}-${local.PROJECT}"
  address_prefix_management = "manual"
  resource_group = data.ibm_resource_group.satellite.id
}

resource "ibm_is_public_gateway" "pg1" {
  name = "${local.PREFIX}-${var.vpc_name}-gw1-${local.PROJECT}"
  resource_group  = data.ibm_resource_group.satellite.id
  vpc  = ibm_is_vpc.sat-vpc.id
  zone = local.ZONE1
}

resource "ibm_is_vpc_address_prefix" "vpc-ap1" {
  name = "${local.PREFIX}-${var.vpc_name}-ap1-${local.PROJECT}"
  zone = local.ZONE1
  vpc  = ibm_is_vpc.sat-vpc.id
  cidr = var.zone1_cidr
}

resource "ibm_is_subnet" "sn1" {
  name            = "${local.PREFIX}-${var.vpc_name}-sn1-${local.PROJECT}"
  resource_group  = data.ibm_resource_group.satellite.id
  vpc             = ibm_is_vpc.sat-vpc.id
  zone            = local.ZONE1
  ipv4_cidr_block = var.zone1_cidr
  public_gateway  = ibm_is_public_gateway.pg1.id
  depends_on      = [ibm_is_vpc_address_prefix.vpc-ap1]
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_ssh" {
  group     = ibm_is_vpc.sat-vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = "22"
    port_max = "22"
  }
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_https" {
  group     = ibm_is_vpc.sat-vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = "443"
    port_max = "443"
  }
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_http" {
  group     = ibm_is_vpc.sat-vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = "80"
    port_max = "80"
  }
}

resource "ibm_is_security_group_rule" "sg1_tcp_rule_iks" {
  group     = ibm_is_vpc.sat-vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = "30000"
    port_max = "32767"
  }
}

resource "ibm_is_security_group_rule" "sg1_udp_rule_iks" {
  group     = ibm_is_vpc.sat-vpc.default_security_group
  direction = "inbound"
  remote    = "0.0.0.0/0"
  udp {
    port_min = "30000"
    port_max = "32767"
  }
}