locals {
  id          = "${var.prefix}-cache-${random_id.suffix[0].hex}"
  bucket_name = var.bucket_name != null ? var.bucket_name : local.id
}