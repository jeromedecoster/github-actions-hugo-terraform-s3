data aws_acm_certificate cert {
  provider    = aws.us_east_1
  domain      = "www.${var.apex_domain}"
  statuses    = ["ISSUED"]
  most_recent = true
}