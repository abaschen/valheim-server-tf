resource "aws_vpc" "app_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Application  = var.appname
    Name = "${var.appname}-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Application = var.appname
  }
}

locals {
  count_subnets = length(var.subnet_zones) # internal and external
  zones = toset(keys(var.subnet_zones))
}

resource "aws_subnet" "external_subnets" {
  for_each = local.zones

  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, var.subnet_zones[each.key] + 1)
  tags = {
    Application  = var.appname
    Name = "${var.appname}-ext-${each.key}"
  }
}

resource "aws_subnet" "internal_subnets" {
  for_each = local.zones

  vpc_id            = aws_vpc.app_vpc.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(aws_vpc.app_vpc.cidr_block, 8, var.subnet_zones[each.key] + 1 + local.count_subnets)
  tags = {
    Application  = var.appname
    Name = "${var.appname}-int-${each.key}"
  }
}


# Add internet access
resource "aws_route_table" "aws-public-route-table" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    # https://docs.aws.amazon.com/vpc/latest/userguide/route-table-options.html#route-tables-internet-gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Application = var.appname
    Name = "${var.appname}-route"
  }
}

resource "aws_route_table_association" "aws-route-table-association" {
  for_each = local.zones

  subnet_id = aws_subnet.external_subnets[each.key].id
  route_table_id = aws_route_table.aws-public-route-table.id
}

resource "aws_security_group" "internal-sg" {
  name        = "interal-sg"
  description = "Allows all traffic from instances within the VPC."
  vpc_id      = aws_vpc.app_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [aws_vpc.app_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = [aws_vpc.app_vpc.cidr_block]
  }

  tags = {
    Application = var.appname
  }
}

resource "aws_security_group" "external-sg" {
  name        = "external-sg"
  description = "Allows selected traffic from internet to VPC."
  vpc_id      = aws_vpc.app_vpc.id

  dynamic "ingress" {
    for_each= var.ports
    content{ 
        from_port = ingress.value[0]
        to_port   = ingress.value[0]
        protocol = ingress.value[1]
        cidr_blocks = ["0.0.0.0/0"]

    }
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Application = var.appname
  }
}

output "internal_subnet_ids" {
  value = [for o in aws_subnet.internal_subnets : o.id]
}

output "external_subnet_ids" {
  value = [for o in aws_subnet.external_subnets : o.id]
}