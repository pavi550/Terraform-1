provider "oci" {
 
 tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaagu5bmovulbef7bydmdymd6fiy22w23qym5gjpf5y7w4hw6eio5uq"
 user_ocid="ocid1.user.oc1..aaaaaaaa34ejhkjzllf3ld4mpulnrvkqvdpyk2724o523e76ahx4xqcmzhua"
 fingerprint="92:07:be:59:88:64:e7:27:a2:b4:2d:c0:8c:83:99:d7"
 private_key_path="/root/.oci/apiprivatekey.pem"
 region="eu-frankfurt-1"
}


data "oci_identity_availability_domains" "testing_availability_domains" {
    #Required
    compartment_id ="ocid1.compartment.oc1..aaaaaaaag4wspnwz7kf3dhbooqoylnmvqhpdju5oap2l6chdlwonngxwka3q"
}


output ad_list {
 value= "${data.oci_identity_availability_domains.testing_availability_domains.availability_domains}"
}
