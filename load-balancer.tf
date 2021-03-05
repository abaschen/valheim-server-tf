
resource "aws_alb" "application_load_balancer" {
  name               = "${var.appname}-loadbalancer"
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
        description = "port[0]/port[1]"

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
  load_balancer_arn = aws_alb.application_load_balancer.arn # Referencing our load balancer
    port        = aws_lb_target_group.target_group[count.index].port
    protocol    = aws_lb_target_group.target_group[count.index].protocol
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group[count.index].arn # Referencing our tagrte group
  }
}