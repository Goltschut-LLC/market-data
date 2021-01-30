resource "aws_s3_bucket" "glue" {
  bucket = "aws-glue-${var.project_name}-${var.env}"
  acl    = "private"
}
