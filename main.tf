provider "vsphere" {
  # If you have a self-signed cert
  allow_unverified_ssl = true
}

provider "aap" {
}

data "vsphere_datacenter" "dc" {
  name = "Shadowman-DC"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Cluster01"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = "LAN02"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = "/Shadowman-DC/vm/${var.rhel_version}_ShadowMan"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "terraformvms" {
  count            = var.number_of_instances
  name             = "${var.instance_name_convention}${count.index}.shadowman.dev"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = "Lab virtual machine"
  firmware         = data.vsphere_virtual_machine.template.firmware
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type

  num_cpus = data.vsphere_virtual_machine.template.num_cpus
  memory   = data.vsphere_virtual_machine.template.memory

  network_interface {
    network_id = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  tags = [
    "urn:vmomi:InventoryServiceTag:008d5941-409f-42bf-af67-69e513e4f3a3:GLOBAL",
    "urn:vmomi:InventoryServiceTag:4a22652c-1463-424a-9353-878197be7088:GLOBAL",
    "urn:vmomi:InventoryServiceTag:55432059-1bb8-4949-81f3-8c44e0747845:GLOBAL",
    "urn:vmomi:InventoryServiceTag:8921ca91-396b-4458-82b4-2221e5b9ce3c:GLOBAL"
  ]

  wait_for_guest_net_timeout = 10
  wait_for_guest_ip_timeout  = -1

  disk {
    label            = "${var.instance_name_convention}${count.index}"
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
    size             = data.vsphere_virtual_machine.template.disks.0.size
  }

  guest_id = data.vsphere_virtual_machine.template.guest_id

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id
  }
}

locals {
  vm_names_csv = join(",", vsphere_virtual_machine.terraformvms[*].name)
}

resource "terraform_data" "vm_change_trigger" {
  input = local.vm_names_csv
}

resource "aap_workflow_job" "configure_vms" {
  workflow_job_template_id = 1279

  extra_vars = jsonencode({
    vm_names          = local.vm_names_csv
    ticket_number     = var.ticket_number
    shadowman_provision_hypervisor = "VMWare"
  })

  lifecycle {
    replace_triggered_by = [terraform_data.vm_change_trigger]
  }

  depends_on = [vsphere_virtual_machine.terraformvms]
}
