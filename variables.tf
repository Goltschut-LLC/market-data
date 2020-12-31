variable "env" {
  type = string
}

variable "region" {
  default = "us-east-1"
}

variable "rds_min_capacity" {
  default = 1
}

variable "rds_max_capacity" {
  default = 2
}
