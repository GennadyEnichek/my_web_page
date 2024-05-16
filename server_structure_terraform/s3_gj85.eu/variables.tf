variable "bucket-name" {
  description = "defines backet name"
  type        = string
  default     = "gj85.eu"
}

variable "index-file" {
  description = "defines website index.html file name - the static file for success html request"
  type        = string
  default     = "index.html"
}

variable "error-file" {
  description = "defines website error.html file name - the static file for unsuccess html request"
  type        = string
  default     = "error.html"
}
