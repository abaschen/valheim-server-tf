
data "aws_route53_zone" "domain" {
  name = "${var.domain}."
  private_zone = false

}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.appname}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.network_load_balancer.dns_name
    zone_id                = aws_lb.network_load_balancer.zone_id
    evaluate_target_health = false
  }
}