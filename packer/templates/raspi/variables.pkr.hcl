variable "password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "fullname" {
  type    = string
  default = ""
}

variable "username" {
  type    = string
  default = ""
}

variable "distribution" {
  type    = string
  default = "ubuntu"
}

variable "version" {
  type    = string
  default = "22.04.3"
}
