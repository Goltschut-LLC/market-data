variable "env" {
  type = string
}

variable "project_name" {
  type = string
}

variable "domain_name" {
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
  default = "us_stock_market"
}

variable "rds_secret_name" {
  default = "rds"
}

variable "alpaca_secret_name" {
  default = "alpaca"
}

variable "ecs_service_desired_count" {
  default = 1
}

variable "ecs_task_cpu" {
  default = 256
}

variable "ecs_task_memory" {
  default = 512
}

variable "sso_username" {
  type = string
}
