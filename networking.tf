
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
