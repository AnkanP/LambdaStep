variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-west-2"
}

variable "bucket" {
  description = "bucketname"
  type        = string
  default     = "crawlerpbucket3"
}


variable "lambda_function_name" {
  description = "default lambda function"
  type        = string
  default     = "crawlerplambda"
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