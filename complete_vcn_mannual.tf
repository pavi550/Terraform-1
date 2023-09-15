# ---- use variables defined in terraform.tfvars or bash profile file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "AD" {}
#--- provider , This matches your env.sh Export Variable declaration.
provider "oci" {
region="${var.region}"
tenancy_ocid="${var.tenancy_ocid}"
user_ocid="${var.user_ocid}"
fingerprint="${var.fingerprint}"
private_key_path="${var.private_key_path}"
}

# -------- get the list of available ADs
data "oci_identity_availability_domains" "ADs" {
 compartment_id="${var.tenancy_ocid}"
}
# ------ Create a new VCN
variable "vcn_cidr" { default = "10.0.0.0/16" }
resource "oci_core_virtual_network" "terraform-vcn" {
 cidr_block="${var.vcn_cidr}"
 compartment_id="${var.compartment_ocid}"
 display_name="terraform-vcn-dj-11-1"
 dns_label="terraformvcn19dj"
}

###--- Create a new NAT Gateway
resource "oci_core_nat_gateway" "terraform-NAT-gateway" {
compartment_id="${var.compartment_ocid}"
display_name="terraform-NAT-gateway-dj-11"
vcn_id="${oci_core_virtual_network.terraform-vcn.id}"
}
# ------ Create a new Internet Gateway
resource "oci_core_internet_gateway" "terraform-ig" {
 compartment_id="${var.compartment_ocid}"
 display_name="terraform-internet-gateway-dj-11"
 vcn_id="${oci_core_virtual_network.terraform-vcn.id}"
}

# ------ Create a new Route Table
resource "oci_core_route_table" "terraform-rt" {
compartment_id="${var.compartment_ocid}"
vcn_id="${oci_core_virtual_network.terraform-vcn.id}"
display_name="terraform-route-table-dj-11"
route_rules {
 destination="0.0.0.0/0"
 network_entity_id="${oci_core_internet_gateway.terraform-ig.id}"
 }
}
resource "oci_core_route_table" "terraform-rt2" {
compartment_id="${var.compartment_ocid}"
vcn_id="${oci_core_virtual_network.terraform-vcn.id}"
display_name="terraform-route-table2-dj-11-2"
route_rules {
destination="0.0.0.0/0"
network_entity_id="${oci_core_nat_gateway.terraform-NAT-gateway.id}"
}
}

# ------ Create a public subnet 1 in AD1 in the new VCN
resource "oci_core_subnet" "terraform-public-subnet1" {
 availability_domain="${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD - 1],"name")}"
 cidr_block="10.0.1.0/24"
 display_name="terraform-public-subnet1-dj-11"
 dns_label="subnet1"
 compartment_id="${var.compartment_ocid}"
 vcn_id="${oci_core_virtual_network.terraform-vcn.id}"
 route_table_id="${oci_core_route_table.terraform-rt.id}"
dhcp_options_id="${oci_core_virtual_network.terraform-vcn.default_dhcp_options_id}"
}
####Create a private subnet 1 in AD2 in the new VCN
resource "oci_core_subnet" "terraform-private-subnet1" {
availability_domain="${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.AD ],"name")}"
 cidr_block="10.0.0.0/24"
 display_name="terraform-private-subnet1-dj-12"
 dns_label="subnet2"
 compartment_id="${var.compartment_ocid}"
 vcn_id="${oci_core_virtual_network.terraform-vcn.id}"
 route_table_id="${oci_core_route_table.terraform-rt2.id}"
 prohibit_public_ip_on_vnic=true
 dhcp_options_id="${oci_core_virtual_network.terraform-vcn.default_dhcp_options_id}"
}




[DEFAULT]
user=ocid1.user.oc1..aaaaaaaa34ejhkjzllf3ld4mpulnrvkqvdpyk2724o523e76ahx4xqcmzhua
fingerprint=92:07:be:59:88:64:e7:27:a2:b4:2d:c0:8c:83:99:d7
tenancy=ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq
region=eu-frankfurt-1
key_file=/root/.oci/apiprivatekey.pem
Subnet OCID =ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa4xv3smdf2nnoephecel3vdbxv3zbgzqc2x3vkfg6telnjr7ykvjq
