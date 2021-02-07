resource "aws_s3_bucket" "glue" {
  bucket = "aws-glue-${var.project_name}-${var.env}"
  acl    = "private"
}

resource "aws_s3_bucket" "public" {
  bucket = "${var.project_name}-${var.env}-public"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_policy" "update_public_bucket_policy" {
  bucket = aws_s3_bucket.public.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PolicyForWebsiteEndpointsPublicContent",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.public.arn}/*",
        "${aws_s3_bucket.public.arn}"
      ]
    }
  ]
}
POLICY
}

# This resource is only run once. To trigger re-upload:
#   terraform state rm null_resource.sync_public_site_to_s3
resource "null_resource" "sync_public_site_to_s3" {
  provisioner "local-exec" {
    command = "aws s3 sync ${path.module}/site/build s3://${aws_s3_bucket.public.id}"
  }
}
