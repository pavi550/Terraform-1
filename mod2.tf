
provider "oci" {

 tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
 user_ocid="ocid1.user.oc1..aaaaaaaa34ejhkjzllf3ld4mpulnrvkqvdpyk2724o523e76ahx4xqcmzhua"
 fingerprint="92:07:be:59:88:64:e7:27:a2:b4:2d:c0:8c:83:99:d7"
 private_key_path="/root/.oci/apiprivatekey.pem"
 region="eu-frankfurt-1"
}


data "oci_identity_availability_domains" "test_availability_domains" {
    #Required
    compartment_id ="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
}

locals{
ad_list="${data.oci_identity_availability_domains.test_availability_domains.availability_domains[*].name}"
}

output display_name {
 value = "${local.ad_list[*]}"
}

resource null_resource demo {
count = length (local.ad_list)
triggers = {
 name = "${count.index} - ${local.ad_list[count.index]}"
}
}

output demo-list {
 value= null_resource.demo
}

USECASE 11: Using modules 
##########################################

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


Usecase11 dir 
#############
 
provider.tf  file 
==========
provider "oci" {

 tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
 user_ocid="ocid1.user.oc1..aaaaaaaa34ejhkjzllf3ld4mpulnrvkqvdpyk2724o523e76ahx4xqcmzhua"
 fingerprint="92:07:be:59:88:64:e7:27:a2:b4:2d:c0:8c:83:99:d7"
 private_key_path="/root/.oci/apiprivatekey.pem"
 region="eu-frankfurt-1"
}


main.tf 
#########

module "dev" {
  source = "./environments/dev"
 }

module "staging" {
  source = "./environments/staging"
}

module "production" {
  source = "./environments/production"
}
++++++++++++++++++++++++++++++++
I have to try adding public key 
+++++++++++++++++++++++++++++++++++++++
https://github.com/oracle-terraform-modules/terraform-oci-compute-instance/issues/67


variable "ssh_public_key" {
  description = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0uWdA7KUmdtzGzxOvhiMPlZLJZ9zY4+siRIVVijgWXmoof0g+LZwruTZPKMZfeNn2/nDFqoNA29GmCP3O2wlM4n4n2nwl9kV4HwNqiSMdvf91Etr7gBicAZ1CGtiDKkzjxYf26DXT4gtCEykve+GmcP6jwZbjR4bYUtQXuqDd6uqCdFAs4pKBKfOY38IdhKfXduWGSYgzWukqCHEr8VlVBUd9+lLjF7ESkDjd/PW2WhMdnKaAquq5LRIOn6jwoJpQ+rTE3Z5Xx2jNfdSPFyUUYp31PlE0aCqFQpxIY0o27D+5IQ7h2fOgoCdVMPuSLCYDb8c9nq2EieoQkpcDwxNH ssh-key-2023-09-11"
  default     = ""  
  type        = string
}
variable "ssh_public_key_path" {
  description = "/root/usecase11/coreinstance/ssh-key-file.key"
  default     = ""
  type        = string
}

resource "oci_core_instance" "this" {
...
metadata = {    
  ssh_authorized_keys = var.ssh_public_key != "" ? var.ssh_public_key : file(var.ssh_public_key_path)
]
...
}
+++++++++++++++++++++++++++++++++++++++
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/jKQiZsVe8AZmlRUAtsq7SsBipVROGQVsM0HDLYSHMZk3gom2O1BJtvsHkXL2EIEo/n/ocuocictrng27/b/tf-praveen-obj123/o/terraform.tfstate



display = [
  "130.61.105.46",
  "130.61.214.118",
]
display = "The Compute Instance ip created is  , 130.61.24.126"


USECASE 12:

terraform {
  backend "http" {
    address = "copy-preauthrequest-url-here"
    update_method = "PUT"
  }
}


main.tf :
+++++++++++++++++++


terraform {
  backend "http" {
    address = "https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/vEuBQN6afUXS1-czE1ALaFryQm6AHfz7o54feWh5pyH0JSCjKmlMeNiSU5c6kldR/n/ocuocictrng27/b/tf-praveen-obj123/o/terraform.tfstate"
    update_method = "PUT"
  }
}
provider "oci" {

 tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
 user_ocid="ocid1.user.oc1..aaaaaaaa34ejhkjzllf3ld4mpulnrvkqvdpyk2724o523e76ahx4xqcmzhua"
 fingerprint="92:07:be:59:88:64:e7:27:a2:b4:2d:c0:8c:83:99:d7"
 private_key_path="/root/.oci/apiprivatekey.pem"
 region="eu-frankfurt-1"
}

variable "compartment_id" {
default="ocid1.compartment.oc1..aaaaaaaag4wspnwz7kf3dhbooqoylnmvqhpdju5oap2l6chdlwonngxwka3q"
}


resource "oci_core_vcn" "simple-vcn" {
 cidr_block="10.0.0.0/16"
 dns_label="vcn2"
 compartment_id=var.compartment_id
 display_name="first-vcn"
}

output "vcnname"{
 value= "${oci_core_vcn.simple-vcn.id}"
}

output display-vcn1 {
value=format("%s -- %s","VCN created is","${oci_core_vcn.simple-vcn.display_name}")
}


Removed the terraform {}
# terraform init
# terraform apply –auto-approve
– migration issue of backend state
# terraform init --migrate-state
# terraform apply –auto-approve

