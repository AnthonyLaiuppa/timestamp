#
# Route53 - DNS 
#

variable "api_ep"{}
variable "web_fe"{}
variable "web_zone"{}

variable "root_domain_name" {
  default = "example.com"
}

variable "www" {
  default = "www.example.com"
}

variable "api" {
  default = "api.exaple.com"
}

resource "aws_route53_zone" "primary" {
  name = "${var.root_domain_name}"
}

resource "aws_route53_record" "www_tf_dns" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.www}"
  type    = "A"
  
  alias {
    name    = "${var.web_fe}"
    zone_id = "${var.web_zone}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_default_dns" {
  zone_id = //It didnt work without hardcoded default zone id here
  name    = "${var.www}"
  type    = "A"
  
  alias { 
    name    = "s3-website.us-east-2.amazonaws.com"
    zone_id = "${var.web_zone}"
    evaluate_target_health = true
  }
}


data "aws_elb_hosted_zone_id" "main" {}

resource "aws_route53_record" "api_default_dns" {
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.api}"
  type    = "A"
  
  alias { 
    name    = "${var.api_ep}"
    zone_id = "${data.aws_elb_hosted_zone_id.main.id}"
    evaluate_target_health = true
  }
}