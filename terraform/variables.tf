variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "address" {
  description = "Vault address"
  type        = string
}

variable "role_id" {
  description = "Vault AppRole role_id"
  type        = string
}

variable "secret_id" {
  description = "Vault AppRole secret_id"
  type        = string
}