locals {
  bucket_name = var.bucket_name != null ? var.bucket_name : "${var.prefix}-cache-${random_id.suffix.hex}"
}
