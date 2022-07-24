# -------------------- Avaiblity zone ---------------------

variable "sub-avail-zone-1" {
  type    = string
  default = "ca-central-1a"

}

variable "sub-avail-zone-2" {
  type    = string
  default = "ca-central-1b"

}

# -------------------- Public Cidr ---------------------

variable "public-cidr-block" {
  type    = string
  default = "0.0.0.0/0"

}

# -------------------- VPC Cidr ---------------------

variable "vpc-cidr-block" {
  type    = string
  default = "10.10.0.0/16"

}

# -------------------- Subnet Cidr ---------------------

variable "sub-ca-1a-cidr-block" {
  type    = string
  default = "10.10.1.0/24"

}

variable "sub-ca-2a-cidr-block" {
  type    = string
  default = "10.10.3.0/24"

}

variable "sub-ca-1b-cidr-block" {
  type    = string
  default = "10.10.2.0/24"

}

variable "sub-ca-2b-cidr-block" {
  type    = string
  default = "10.10.4.0/24"

}

# -------------------- AMI ---------------------

variable "ami-wp" {
  type    = string
  default = "ami-0003b7cfcbc725663"

}

variable "ami-bs" {
  type    = string
  default = "ami-024f771f651700c2c"

}

variable "ami-ub" {
  type    = string
  default = "ami-0b6937ac543fe96d7"

}

# -------------------- Authantication key ---------------------

variable "key-name" {
  type    = string
  default = "aws-auth-key"

}

variable "instance-type" {
  type    = string
  default = "t2.micro"

}