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
