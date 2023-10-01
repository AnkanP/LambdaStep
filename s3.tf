# This S3 bucket will not be created
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  create_bucket = true
  bucket        = var.bucket
  #bucket_prefix = "crawlerp"
  force_destroy = true
  # ... omitted
  tags = var.tags
}

resource "aws_s3_bucket_notification" "notification" {
  bucket = module.s3_bucket.s3_bucket_id

  lambda_function {
    lambda_function_arn = module.lambda_function.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]

    #filter_prefix = "foldername"
    #filter_suffix = "suffix"

  }
  depends_on = [aws_lambda_permission.s3_permission_to_trigger_lambda]

}
