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

variable "version" {
  type    = string
  default = "22.04.1"
}

variable "file_url" {
  type    = string
  default = "https://cdimage.ubuntu.com/releases/22.04.1/release/ubuntu-22.04.1-preinstalled-desktop-arm64+raspi.img.xz"
}

variable "file_checksum_url" {
  type    = string
  default = "https://cdimage.ubuntu.com/releases/22.04.1/release/SHA256SUMS"
}
