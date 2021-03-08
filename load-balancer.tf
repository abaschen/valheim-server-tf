
resource "aws_lb" "network_load_balancer" {
  name               = "${var.appname}-loadbalancer"
  load_balancer_type = "network"
  subnets = [for o in aws_subnet.external_subnets : o.id]

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
    vpc_id      = aws_vpc.app_vpc.id # Referencing the default VPC
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
  load_balancer_arn = aws_lb.network_load_balancer.arn # Referencing our load balancer
    port        = aws_lb_target_group.target_group[count.index].port
    protocol    = aws_lb_target_group.target_group[count.index].protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn # Referencing our tagrte group
  }
}