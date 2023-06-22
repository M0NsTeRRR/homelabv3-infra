resource "vsphere_tag_category" "category" {
  name        = "terraform"
  description = "Managed by Terraform"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine"
  ]
}

resource "vsphere_tag" "tag" {
  for_each      = toset(var.tags)
  name          = each.key
  category_id = "${vsphere_tag_category.category.id}"
  description = "Managed by Terraform"
}