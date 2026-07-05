variable "aws_region" {
  type        = string
  description = "Target cloud region for resource allocations"
  default     = "ap-south-1"
}

variable "administrator_ip" {
  type        = string
  description = "Public IP address in CIDR notation (e.g., '157.44.10.25/32') for isolated admin access"
}