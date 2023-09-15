#e variables defined in .bash_profile file
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "AD" {}
variable “namespace” {}
#--- provider
provider "oci" {
region = "${var.region}"
tenancy_ocid = "${var.tenancy_ocid}"
user_ocid = "${var.user_ocid}"
fingerprint = "${var.fingerprint}"
private_key_path = "${var.private_key_path}"
}

####Creation of new bucket 

resource "oci_objectstorage_bucket" "terraform-bucket" {
 compartment_id = "${var.compartment_ocid}"
 namespace = "${var.namespace}"
 name = "tf-example-bucket-praveen"
 access_type = "NoPublicAccess"
}

output display {
value=oci_objectstorage_bucket.terraform-bucket.namespace
