terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = ">= 2.12"
    }
    aap = {
      source = "ansible/aap"
    }
  }

  required_version = "~> 1.2"

}
