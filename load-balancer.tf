
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default_vpc.id

  tags = {
    Application = var.appname
  }
}
resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Application  = var.appname
  }
}

resource "aws_subnet" "default_subnet" {
  count = length(var.subnet_zones)

  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = var.subnet_zones[count.index]
  cidr_block        = cidrsubnet(aws_vpc.default_vpc.cidr_block, 8, count.index + 1)
  tags = {
    Application  = var.appname
  }
}

data "aws_route53_zone" "domain" {
  name = "${var.domain}."
  private_zone = false

}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = "${var.appname}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.application_load_balancer.dns_name
    zone_id                = aws_lb.application_load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb" "application_load_balancer" {
  name               = "${var.appname}-loadbalancer"
  load_balancer_type = "network"
  subnets = aws_subnet.default_subnet[*].id

  tags = {
    Application  = var.appname
  }
}

resource "aws_lb_target_group" "target_group" {
    count = length(var.ports)
    name        = "${var.appname}-target-group-${var.ports[count.index][0]}-${var.ports[count.index][1]}"
    port        = var.ports[count.index][0]
    protocol    = upper(var.ports[count.index][1])
    target_type = "ip"
    vpc_id      = aws_vpc.default_vpc.id # Referencing the default VPC
    # TODO add healthcheck when they have one
    #health_check {
    #    matcher = "200,301,302"
    #    path = "/"
    #}

  tags = {
    Application  = var.appname
  }
}

resource "aws_lb_listener" "listener" {
  count = length(aws_lb_target_group.target_group)
  load_balancer_arn = aws_lb.application_load_balancer.arn # Referencing our load balancer
    port        = aws_lb_target_group.target_group[count.index].port
    protocol    = aws_lb_target_group.target_group[count.index].protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn # Referencing our tagrte group
  }
}