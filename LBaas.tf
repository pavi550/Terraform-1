# ---- use variables
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
#variable "AD" {}
#--- provider
provider "oci" {
  #region = "${var.region}"
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

variable "instance_image_ocid" {
  type = map(any)
  default = {
    // See https://docs.us-phoenix-1.oraclecloud.com/images/
    // Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
    us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaoqj42sokaoh42l76wsyhn3k2beuntrh5maj3gmgmzeyr55zzrwwa"
    us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
    eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7sfphoisa77bnblpnel74get6vzoofo4xix535nwdmfsnbscm4xa"
    uk-london-1    = "ocid1.image.oc1.uk-london1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"
  }
}
variable "instance_shape" {
  default = "VM.Standard.A1.Flex"
}
variable "availability_domain" {
  default = 1
}

variable ssh_public_key {
default="ssh-key-file.key"
}

data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}


#NETWORK 

resource "oci_core_virtual_network" "vcn-web" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "vcn-web-dj"
  dns_label      = "vcnweb"
}


# Security List

resource "oci_core_security_list" "LB-Security-List" {
  display_name   = "LB-Security-List"
  compartment_id = oci_core_virtual_network.vcn-web.compartment_id
  vcn_id         = oci_core_virtual_network.vcn-web.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }
}


resource "oci_core_default_security_list" "default-securitylist" {
  manage_default_resource_id = oci_core_virtual_network.vcn-web.default_security_list_id
  egress_security_rules  {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
  ingress_security_rules  {

      
        tcp_options  {
            min = "22"
            max = "22"
        }

        protocol = "6"
        source   = "0.0.0.0/0"
       }

      ingress_security_rules {
        
          tcp_options  {
            min = 80
            max = 80
        }

        protocol = "6"
        source   = "0.0.0.0/0"
       }  
}

#ROute table and gateway 

resource "oci_core_default_route_table" "default-route-table" {
  manage_default_resource_id = oci_core_virtual_network.vcn-web.default_route_table_id
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internetgateway1.id
  }
}
resource "oci_core_internet_gateway" "internetgateway1" {
  compartment_id = var.compartment_ocid
  display_name   = "internetgateway1"
  vcn_id         = oci_core_virtual_network.vcn-web.id
}
resource "oci_core_route_table" "LB-Route-Table" {
  compartment_id = var.compartment_ocid
  display_name   = "routetable1"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internetgateway1.id
  }
  vcn_id = oci_core_virtual_network.vcn-web.id
}

# subnet - regional
resource "oci_core_subnet" "lb-subnet1" {
  #availability_domain = "${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain -3],"name")}"
  cidr_block        = "10.0.0.0/24"
  display_name      = "lb-subnet1"
  dns_label         = "lbsubnet1"
  security_list_ids = ["${oci_core_security_list.LB-Security-List.id}"]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn-web.id
  route_table_id    = oci_core_route_table.LB-Route-Table.id
  dhcp_options_id   = oci_core_virtual_network.vcn-web.default_dhcp_options_id
  provisioner "local-exec" {
    command = "sleep 5"
  }
}
resource "oci_core_subnet" "lb-subnet2" {
  #availability_domain ="${lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain -2],"name")}"
  cidr_block        = "10.0.1.0/24"
  display_name      = "lb-subnet2"
  dns_label         = "lbsubnet2"
  security_list_ids = ["${oci_core_security_list.LB-Security-List.id}"]
  compartment_id    = var.compartment_ocid
  vcn_id            = oci_core_virtual_network.vcn-web.id
  route_table_id    = oci_core_route_table.LB-Route-Table.id
  dhcp_options_id   = oci_core_virtual_network.vcn-web.default_dhcp_options_id
  provisioner "local-exec" {
    command = "sleep 5"
  }
}
resource "oci_core_subnet" "web-server" {
  #availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")
  cidr_block   = "10.0.2.0/24"
  display_name = "web-server"
  dns_label    = "webserver"
  # security_list_ids = ["${oci_core_security_list.vcn-web.default_security_list_id}"]
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_virtual_network.vcn-web.id
  # route_table_id = "${oci_core_route_table.vcn-web.default_route_id}"
  dhcp_options_id = oci_core_virtual_network.vcn-web.default_dhcp_options_id
  provisioner "local-exec" {
    command = "sleep 5"
  }
}

#Instace creation 

/* Instances */
resource "oci_core_instance" "websrv1" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "websrv1"
  shape               = var.instance_shape
  #subnet_id           = oci_core_subnet.web-server.id
  hostname_label = "websrv1"
  shape_config {
   ocpus=1
    memory_in_gbs=8
  }
   
  metadata = {
    ssh_authorized_keys = file("${var.ssh_public_key}")
  }
  create_vnic_details {
    subnet_id = oci_core_subnet.web-server.id
  }
  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }
  provisioner "file" {
     connection {
       type = "ssh"
       port = 22
       user = "opc"
       agent = "false"
       host     = self.public_ip
       private_key = "${file("sshprivatekey.key")}"
       }


    source      = "script.sh"
    destination = "/home/opc/script.sh"
  }

  provisioner "remote-exec" {
    connection {
       type = "ssh"
       port = 22
       user = "opc"
       agent = "false"
       host     = self.public_ip
       private_key = "${file("sshprivatekey.key")}"
       }
    inline = [
      "chmod +x /home/opc/script.sh",
      "source /home/opc/script.sh ",
    ]
  }

}

resource "oci_core_instance" "websrv2" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[var.availability_domain - 1], "name")
  compartment_id      = var.compartment_ocid
  display_name        = "websrv2"
  shape               = var.instance_shape
  #subnet_id           = oci_core_subnet.web-server.id
  hostname_label = "websrv2"
  shape_config {
   ocpus=1
    memory_in_gbs=8
  }
   
  metadata = {
    ssh_authorized_keys = file("${var.ssh_public_key}")
  }
  create_vnic_details {
    subnet_id = oci_core_subnet.web-server.id
  }
  source_details {
    source_type = "image"
    source_id   = var.instance_image_ocid[var.region]
  }
  provisioner "file" {
     connection {
       type = "ssh"
       port = 22
       user = "opc"
       agent = "false"
       host     = self.public_ip
       private_key = "${file("sshprivatekey.key")}"
       }


    source      = "script.sh"
    destination = "/home/opc/script.sh"
  }

  provisioner "remote-exec" {
    connection {
       type = "ssh"
       port = 22
       user = "opc"
       agent = "false"
       host     = self.public_ip
       private_key = "${file("sshprivatekey.key")}"
       }
    inline = [
      "chmod +x /home/opc/script.sh",
      "source /home/opc/script.sh ",
    ]
  }

}

/* Load Balancer oci_load_balancer_load_balancer */
resource "oci_load_balancer" "lb1" {
  shape          = "10Mbps"
  compartment_id = var.compartment_ocid
  subnet_ids = [
   "${oci_core_subnet.web-server.id}", 
  ]
  display_name = "LB-Web-Servers"
}

# Health and Route


resource "oci_load_balancer_backend_set" "lb-bes1" {
  name             = "lb-bes1"
  load_balancer_id = oci_load_balancer.lb1.id
  policy           = "ROUND_ROBIN"

 health_checker {
    port     = "80"
    protocol = "HTTP"
    url_path = "/"
  }
}

#listeners to LB 

resource "oci_load_balancer_listener" "lb-listener1" {
  load_balancer_id         = oci_load_balancer.lb1.id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-bes1.name
  port                     = 80
  protocol                 = "HTTP"
  connection_configuration {
    idle_timeout_in_seconds = "8"
  }
}
resource "oci_load_balancer_backend" "lb-be1" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.websrv1.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
resource "oci_load_balancer_backend" "lb-be2" {
  load_balancer_id = oci_load_balancer.lb1.id
  backendset_name  = oci_load_balancer_backend_set.lb-bes1.name
  ip_address       = oci_core_instance.websrv2.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}


output "lb_public_ip" {
  value = ["${oci_load_balancer.lb1.ip_addresses}"]
}
output "public-ips" {
  value = "${oci_core_instance.websrv1.public_ip} - ${oci_core_instance.websrv2.public_ip}"
}
