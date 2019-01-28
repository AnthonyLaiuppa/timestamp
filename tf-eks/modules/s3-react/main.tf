#
# S3 - Used to host our react front end
#


resource "aws_s3_bucket" "feb" {
  bucket = "www.example.com"
  //Set read permissions
  acl    = "public-read"
  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::www.example.com/*"]
    }
  ]
}
POLICY
  force_destroy = true

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  //CORS needed 
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["http://www.example.com", "http://api.example.com"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  versioning {
    enabled = true
  }

  //Load our bucket
  //Youll need something like this in package.json
  //"deploy": "aws s3 sync /Users/user/timestamp/src/react/timestamp/build s3://www.example.com",
  provisioner "local-exec" {
    command = "cd ../src/react/timestamp && npm run build && npm run deploy"
   }

}

output "web_ep" {
  value = "${aws_s3_bucket.feb.website_endpoint}"
  depends_on = [
  "aws_s3_bucket.feb"
  ]
}

output "web_zone" {
  value = "${aws_s3_bucket.feb.hosted_zone_id}"
  depends_on = [
  "aws_s3_bucket.feb"
  ]
}