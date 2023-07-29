#create a domain certificate - https certificate for load balance and cluster, validation to this domain - secure on browser when trying to reach services from internet

resource "aws_acm_certificate" "ecs_domain_certificate" {
  domain_name       = "tekhulk.com"
  validation_method = "DNS"

  tags = {
    name = "ecs_cluster_name_certificate"
  }
}

#DNS validation with Route53
data "aws_route53_zone" "ecs_domain" {
    name = "tekhulk.com"
    private_zone = false
}


resource "aws_route53_record" "ecs_cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.ecs_domain_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.ecs_domain.zone_id
}



resource "aws_acm_certificate_validation" "ecs_domain_certificate_validation" {
  certificate_arn         = aws_acm_certificate.ecs_domain_certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.ecs_cert_validation_record : record.fqdn]
}


resource "aws_route53_record" "ecs_load_balancer_record" {
  zone_id = data.aws_route53_zone.ecs_domain.zone_id
  name    = "www.tekhulk.com"
  type    = "A"
#   ttl     = 60
  
  allow_overwrite = true
  alias {
    evaluate_target_health = false
    name = aws_lb.application_lb.dns_name
    zone_id = aws_lb.application_lb.zone_id
  }
}

# resource "aws_cloudfront_distribution" "flaskapp_distribution" {

# }