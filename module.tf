
[root@terrforminstance usecase11]# tree -a
.
├── coreinstance
└── environments
    ├── dev
    ├── production
    └── staging

5 directories, 0 files


coreinstance/main.tf
#############################
data "oci_identity_availability_domains" "test_availability_domains" {
    #Required
    compartment_id ="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"

}


resource "oci_core_instance" "oracle_instance" {
    # Required
    availability_domain = "${data.oci_identity_availability_domains.test_availability_domains.availability_domains[0].name}"
    compartment_id = "ocid1.compartment.oc1..aaaaaaaag4wspnwz7kf3dhbooqoylnmvqhpdju5oap2l6chdlwonngxwka3q"
    shape = "VM.Standard.A1.Flex"
	shape_config {
   ocpus=1
    memory_in_gbs=8
  }

    display_name="${var.environment}"
    create_vnic_details {
        assign_public_ip = true
        subnet_id = "ocid1.subnet.oc1.eu-frankfurt-1.aaaaaaaa4xv3smdf2nnoephecel3vdbxv3zbgzqc2x3vkfg6telnjr7ykvjq"
    }
source_details {
        source_id = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7sfphoisa77bnblpnel74get6vzoofo4xix535nwdmfsnbscm4xa"
        source_type = "image"
     }
   
}


coreinstance/variables.tf
========================

variable "environment" {}
variable "node_count" {}
variable "node_type" {}
variable display_name {}
variable "availability_domain" { type = list }

environments/dev/Main.tf
=======================

module "dev-coreinstance" {
  source             = "../../coreinstance"
  display_name       = "devinstance"
  environment        = "dev"
  node_count         = 1
  node_type          = "ORACLELOGVM.Standard.E.2.2"
  availability_domain = ["FD1"]
}

environments/staging/Main.tf
===============================

module "staging-coreinstance" {
  source             = "../../coreinstance"
  display_name       = "staginginstance"
  environment        = "staging"
  node_count         = 1
  node_type          = "ORACLELOGVM.Standard.E.2.1"
  availability_domain = ["FD3"]
}


environments/production/main.tf
######################################


module "production-coreinstance" {
  source             = "../../coreinstance"
  display_name       = "productioninstance"
  environment        = "production"
  node_count         = 1
  node_type          = "ORACLELOGVM.Standard.E.2.3"
  availability_domain = ["FD2"]
}
