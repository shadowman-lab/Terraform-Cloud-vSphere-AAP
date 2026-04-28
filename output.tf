# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "vm_name_terraformvms" {
  value = vsphere_virtual_machine.terraformvms[*].name
}

output "aap_job_url" {
  value = aap_workflow_job.configure_vms.url
}

output "aap_job_url" {
  value = aap_workflow_job.configure_vms.status
}
