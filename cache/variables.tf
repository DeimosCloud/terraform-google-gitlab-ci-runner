
variable "bucket_name" {
  description = "Name of the gcs storage bucket to be created."
  type        = string
  default     = null
}

variable "bucket_versioning" {
  description = "Boolean used to enable versioning on the cache bucket, false by default."
  type        = bool
  default     = false
}

variable "bucket_location" {
  description = "The location where to create the cache bucket in."
  type        = string
}

variable "bucket_storage_class" {
  description = "The cache storage class"
  default     = "STANDARD"
}

variable "bucket_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 2
}

variable "bucket_labels" {
  description = "labels to apply to the storage bucket"
  type        = map(string)
  default     = {}
}

variable "prefix" {
  description = "string to prepend to the cache service account id"
  type        = string
  default     = "gitlab-runner"
}
