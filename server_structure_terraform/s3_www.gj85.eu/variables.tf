variable "bucket-name" {
  description = "defines backet name"
  type        = string
  default     = "www.gj85.eu"
}

variable "host-to-redirect" {
  description = "Defines the name of host for redirection from www bucket"
  type        = string
  default     = "gj85.eu"
}

variable "redirection-protocol" {
  description = "Defines the protocol which used for redirection"
  type        = string
  default     = "http"

}
