variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}
variable "namespace" {}
variable "tenancy_ocid" {}
#--- provider
provider "oci" {
region = "${var.region}"
tenancy_ocid = "${var.tenancy_ocid}"
user_ocid = "${var.user_ocid}"
fingerprint = "${var.fingerprint}"
private_key_path = "${var.private_key_path}"
}

#Create new bucket 

resource "oci_objectstorage_bucket" "bucket1" {
 compartment_id = "${var.compartment_ocid}"
 namespace = "${var.namespace}"
 name = "tf-praveen-obj123"
 access_type = "NoPublicAccess"
}

#Create object in bucket 

resource oci_objectstorage_object "object" {
  bucket="${oci_objectstorage_bucket.bucket1.name}"
  object="test-object-empty-object-pk1"
  namespace="${var.namespace}"
  depends_on =[ oci_objectstorage_bucket.bucket1 ]
}

#Provide access to object 

resource "oci_objectstorage_preauthrequest" "test_preauthenticated_request" {
 #Required
 access_type = "AnyObjectRead"
 bucket = "${oci_objectstorage_bucket.bucket1.name}"
 name = "terraform-preauth-dj16"
 namespace = "${var.namespace}"
 time_expires = "2023-09-16T00:09:51.000+02:00"
 #Optional
 depends_on =[ oci_objectstorage_bucket.bucket1,oci_objectstorage_object.object ]
}

#OUTPUT DISPLAY 

output print_uri {
value=oci_objectstorage_preauthrequest.test_preauthenticated_request.access_uri
}
