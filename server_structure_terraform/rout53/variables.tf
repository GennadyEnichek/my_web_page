variable "hosted-zone-name" {
  description = "The name of the AWS hosted zone"
  type        = string
  default     = "gj.eu"
}

variable "host-record-name" {
  description = "Record for host domain"
  type        = string
  default     = "gj.eu"
}

variable "www-record-name" {
  description = "Record for www domain"
  type        = string
  default     = "www.gj.eu"
}
