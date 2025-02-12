variable "sg_name" {
  description = "Security Group name"
  type        = string
  default     = "default_local_host_sg"
}

variable "sg_description" {
  description = "Security Group description"
  type        = string
  default     = "Security group for SSH and HTTP from local host"
}
