variable "project_id" {
  description = "trabalho-01-iaac"
}

variable "region" {
  description = "The region to deploy to"
  default     = "us-east4"
}

variable "network" {
  description = "The GCP network to launch the instance in"
  default     = "default"
}

