variable "region" {
  type        = string
  description = "Pass region to providers"
  default     = "us-east-1"
}
variable "name_prefix" {
  type        = string
  description = "Names for all the resources"
  default     = "golf"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC-CIDR"
  default     = "10.0.0.0/16"
}
variable "availability_z" {
  description = "AZS"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}
variable "pub_subnet_cidr" {
  description = "CIDR-SUBNET"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "priv_subnet_cidr" {
  description = "CIDR-SUBNET"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "cidr_rt" {
  description = "RT-CIDR"
  type        = string
  default     = "0.0.0.0/0"
}
variable "nat_per_az" {
  description = "NGW Per AZ"
  type        = bool
  default     = true
}
variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t3-micro"
}
variable "ports" {
  description = "Ports"
  type        = list(string)
  default     = ["443", "80"]
}
