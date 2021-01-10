variable "env" {
  type = string
}

variable "region" {
  default = "us-east-1"
}

variable "max_az_count" {
  default = 8
}

variable "rds_min_capacity" {
  default = 1
}

variable "rds_max_capacity" {
  default = 2
}

variable "rds_username" {
  type = string
}

variable "rds_database_name" {
  default = "market"
}

variable "rds_secret_name" {
  default = "rds"
}

variable "alpaca_secret_name" {
  default = "alpaca"
}
