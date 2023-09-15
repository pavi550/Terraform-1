# ---- use variables defined in terraform.tf vars or bash
# --profile file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "AD" {}
variable "subnet_id" {}
#--- provider
provider "oci" {
region="${var.region}"
tenancy_ocid="${var.tenancy_ocid}"
user_ocid="${var.user_ocid}"
fingerprint="${var.fingerprint}"
private_key_path="${var.private_key_path}"
}


variable ssh-key-file {
default="ssh-key-file.key"
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}


resource "oci_core_instance" "oracle_instance" {
    # Required
    # https://docs.oracle.com/en-us/iaas/images/image/81eb1ed9-cea8-4c6f-832d-e41f7741b812/
   count=2
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = "${var.compartment_ocid}"
    shape = "VM.Standard.A1.Flex"
    shape_config {
      memory_in_gbs=12
      ocpus=1
     }


    source_details {
        source_id = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa7sfphoisa77bnblpnel74get6vzoofo4xix535nwdmfsnbscm4xa"
        source_type = "image"
    }


    # Optional
  
   display_name =format("%s-%s", "oraclelinux-dj",count.index)
    hostname_label=format("%s%s","oraclelinux",count.index)

    create_vnic_details {
        assign_public_ip = true
        subnet_id = "${var.subnet_id}"
    }
    metadata = {
        ssh_authorized_keys = file("${var.ssh-key-file}")
    }
    preserve_boot_volume = false

 provisioner "file" {
     connection {
       type = "ssh"
       port = 22
       user = "opc"
       agent = "false"
       host     = self.public_ip
       private_key = "${file("sshprivatekey")}"
       }


    source      = "ssh-key-file.key"
    destination = "/home/opc/ssh-key-file.key"
  }


  provisioner "remote-exec" {
     connection {
       type = "ssh"
       port = 22
       user = "opc"
       agent = "false"
       host     = self.public_ip
       private_key = "${file("sshprivatekey")}"
       }
     inline = [
      "echo connection successful",
       "cat /home/opc/ssh-key-file.key"


       ]

    }

}

##output display {
#value=format("%s,%s", "The Compute Instance ip created is ",oci_core_instance.oracle_instance[*].public_ip)
#}
#use below to nullify error
output display {
value=oci_core_instance.oracle_instance[*].public_ip
}


" Compute Instance ip created is ${oci_core_instance.demo_instance[*].public_ip}"

or 

value=join("--",oci_core_instance.oracle_instance[*].public_ip)

