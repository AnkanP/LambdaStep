variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "bucket" {
  description = "bucketname"
  type        = string
  default     = "crawlerpbucket5"
}


variable "lambda_function_name" {
  description = "default lambda function"
  type        = string
  default     = "crawlerplambda"
}


variable "lambda_function_name_rds" {
  description = "default lambda function"
  type        = string
  default     = "crawlerplambda_rds"
}


variable "step_function_name" {
  description = "default step function"
  type        = string
  default     = "crawlerpstepfunction"
}

variable "tags" {
  description = "list of tags"
  type        = map(any)
  default = {
    name = "crawlerptest"
    env  = "poc"
  }
}