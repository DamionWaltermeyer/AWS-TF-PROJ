
resource "aws_vpc" "main" { #instantiate 
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true # internal dns resolution
  enable_dns_hostnames = true # public dns
  tags                 = local.common_tags
}

resource "aws_internet_gateway" "igw" { #make internet gateway for connectivity
  vpc_id = aws_vpc.main.id
  tags   = local.common_tags
}

resource "aws_subnet" "public" { #subnets- two for availability 
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false # Public IPs avoided for security - ALB/WAF instead 

  tags = merge(local.common_tags, {
    Name = "public-subnet-${count.index + 1}"
  })
}


resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    local.common_tags,
    {
      Name = "private-subnet-${count.index + 1}"
    }
  )
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = local.common_tags
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

data "aws_availability_zones" "available" {}

resource "aws_eip" "nat" {
  domain = "vpc"

}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.igw]

  tags = local.common_tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = local.common_tags
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
