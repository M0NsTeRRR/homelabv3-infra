packer {
  required_version = "v1.9.2"
}

locals {
  file_checksum_type = "sha256"
  file_url           = "https://cdimage.ubuntu.com/releases/${var.version}/release/ubuntu-${var.version}-preinstalled-desktop-arm64+raspi.img.xz"
  file_checksum_url  = "https://cdimage.ubuntu.com/releases/${var.version}/release/${upper(local.file_checksum_type)}SUMS"
}

source "arm" "ubuntu" {
  file_urls             = [local.file_url]
  file_checksum_url     = local.file_checksum_url
  file_checksum_type    = local.file_checksum_type
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  image_build_method    = "reuse"
  image_path            = "raspi-${var.distribution}-${var.version}.img"
  image_size            = "3.1G"
  image_type            = "dos"
  image_partitions {
    name         = "boot"
    type         = "c"
    start_sector = "2048"
    filesystem   = "fat"
    size         = "256M"
    mountpoint   = "/boot/firmware"
  }
  image_partitions {
    name         = "root"
    type         = "83"
    start_sector = "526336"
    filesystem   = "ext4"
    size         = "2.8G"
    mountpoint   = "/"
  }
  image_chroot_env             = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  qemu_binary_source_path      = "/usr/bin/qemu-aarch64-static"
  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.arm.ubuntu"]

  provisioner "shell" {
    inline = [
      "useradd -m -p ${var.password} -s /bin/bash ${var.username} -c '${var.fullname}'",
      "usermod -aG sudo ${var.username}",
      "touch /boot/ssh"
    ]
  }

}
