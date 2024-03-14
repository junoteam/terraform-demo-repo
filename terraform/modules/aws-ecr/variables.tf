variable "tags" {
  type        = map(any)
  default     = {}
  description = "ECR tags"
}

variable "name" {
  type        = string
  default     = ""
  description = "ECR repo name"
}