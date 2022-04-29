
variable "bucket_name" {
  description = "Name of the gcs storage bucket to be created."
  type        = string
}

variable "cache_bucket_versioning" {
  description = "Boolean used to enable versioning on the cache bucket, false by default."
  type        = bool
  default     = false
}

variable "cache_location" {
  description = "The location where to create the cache bucket in. If not specified, it defaults to the region"
}

variable "cache_storage_class" {
  description = "The cache storage class"
  default     = "STANDARD"
}

variable "cache_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 2
}

variable "labels" {
  description = "labels to apply to the storage bucket"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  description = "string to prepend to the cache service account id"
  type        = string
  default     = "ci"
}
