variable "rhel_version" {
  description = "RHEL Version"
  default     = "RHEL9"
}

variable "ticket_number" {
  description = "SNOW Ticket Number"
  default     = ""
}

variable "instance_name_convention" {
  description = "VM instance name convention"
  default     = "web"
}

variable "number_of_instances" {
  description = "VM number of instances"
  type        = number
  default     = 3
}
