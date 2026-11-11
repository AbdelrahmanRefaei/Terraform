# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-vpc"
    }
  )
}
# IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-igw"
    }
  )
}
# Public Subnets
resource "aws_subnet" "public" {
  count             = length(var.availability_z)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.pub_subnet_cidr[count.index]
  availability_zone = var.availability_z[count.index]
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-publicsub-${count.index + 1}"
    }
  )
}
# Public Route Tables 
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-public-rt"
    }
  )
}
resource "aws_route" "pub-routes" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = var.cidr_rt
  gateway_id             = aws_internet_gateway.this.id
}
resource "aws_route_table_association" "pub-as" {
  count          = length(var.availability_z)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.pub_rt.id
}

# Private Route Tables & Subnets
resource "aws_subnet" "private" {
  count             = length(var.availability_z)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.priv_subnet_cidr[count.index]
  availability_zone = var.availability_z[count.index]
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-privatesub-${count.index + 1}"
    }
  )
}
resource "aws_route_table" "private_rt" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-private-rt-${count.index + 1}"
    }
  )
}
resource "aws_route" "priv-routes" {
  count                  = length(aws_subnet.private)
  route_table_id         = aws_route_table.private_rt[count.index].id
  destination_cidr_block = var.cidr_rt
  gateway_id             = aws_nat_gateway.ngw[count.index].id
}
resource "aws_route_table_association" "private-as" {
  count          = length(aws_route.priv-routes)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id
}
# Elastic IP & Nat Gateway
resource "aws_eip" "nat_eip" {
  count  = var.nat_per_az ? length(var.availability_z) : 1
  domain = "vpc"
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-nat-eip-${count.index + 1}"
    }
  )
}
resource "aws_nat_gateway" "ngw" {
  count         = var.nat_per_az ? length(var.availability_z) : 1
  subnet_id     = aws_subnet.private[count.index].id
  allocation_id = aws_eip.nat_eip[count.index].id
  tags = merge(
    local.common_tags,
    {
      "Name" = "${var.name_prefix}-natgateway-${count.index + 1}"
    }
  )
  depends_on = [aws_internet_gateway.this]
}

