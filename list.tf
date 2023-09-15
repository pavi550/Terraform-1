provider "oci" {
 
 tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
 user_ocid="ocid1.user.oc1..aaaaaaaa34ejhkjzllf3ld4mpulnrvkqvdpyk2724o523e76ahx4xqcmzhua"
 fingerprint="92:07:be:59:88:64:e7:27:a2:b4:2d:c0:8c:83:99:d7"
 private_key_path="/root/.oci/apiprivatekey.pem"
 region="eu-frankfurt-1"
}

variable "tenancy_ocid" {
default="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
}

data "oci_identity_availability_domains" "test_availability_domains" {
    #Required
    compartment_id = "${var.tenancy_ocid}"
}

output ad_list1 {
value= "${data.oci_identity_availability_domains.test_availability_domains.availability_domains}"
}
output ad_list2 {
value="the data list is data.oci_identity_availability_domains.test_availability_domains.availability_domains"
}

output domain_name1 {
value=format("%s--%s","domain",lookup(data.oci_identity_availability_domains.test_availability_domains.availability_domains[1],"name"))

}

output domain_name2 {
value=data.oci_identity_availability_domains.test_availability_domains.availability_domains[*].name
}

output ad_list3 {
value=lookup(data.oci_identity_availability_domains.test_availability_domains.availability_domains[0],"id")
}