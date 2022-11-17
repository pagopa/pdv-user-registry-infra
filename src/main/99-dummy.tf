resource "random_string" "test" {
  length           = 16
  special          = true
  override_special = "/@£$"
}