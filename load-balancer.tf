
resource "aws_alb" "application_load_balancer" {
  name               = "valheim-loadbalancer"
  load_balancer_type = "application"
  subnets = aws_subnet.default_subnet[*].id
  # Referencing the security group
  security_groups = [aws_security_group.load_balancer_security_group.id]
  tags = {
    Application  = var.appname
  }
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {

  ingress = [
    for port in var.ports: {
        from_port   = port[0] # Allowing traffic in from port 2456
        to_port     = port[0]
        protocol    = port[1]
        cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
        
        ipv6_cidr_blocks= null
        prefix_list_ids= null
        security_groups= null
        self= null
    }
  ]

  egress {
    from_port   = 0 # Allowing any incoming port
    to_port     = 0 # Allowing any outgoing port
    protocol    = "-1" # Allowing any outgoing protocol 
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic out to all IP addresses
  }

  tags = {
    Application  = var.appname
  }
}

resource "aws_lb_target_group" "target_group" {
    for_each = var.ports
    name        = "valheim-target-group-${each.key}"
    port        = each.value
    protocol    = "UDP"
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
  for_each = var.ports
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
  port              = each.value
  protocol          = "UDP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[each.key].arn # Referencing our tagrte group
  }
}