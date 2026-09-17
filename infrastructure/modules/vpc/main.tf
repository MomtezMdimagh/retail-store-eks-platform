
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, {
    Name        = "${var.environment_name}-vpc"
    Environment = var.environment_name
  })
  lifecycle {
    prevent_destroy = false # change in production to true
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-igw"
    Environment = var.environment_name
  })
}

resource "aws_subnet" "public" {
  for_each                = local.public_subnet_cidrs
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = merge(var.tags, {
    Name                                        = "${var.environment_name}-public-${each.key}"
    Environment                                 = var.environment_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  })
}

resource "aws_subnet" "private" {
  for_each          = local.private_subnet_cidrs
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key
  tags = merge(var.tags, {
    Name                                        = "${var.environment_name}-private-${each.key}"
    Environment                                 = var.environment_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  })
}

#Elastic ip for NAT
resource "aws_eip" "nat" {
  tags = merge(var.tags, {
    Name        = "${var.environment_name}-nat-eip"
    Environment = var.environment_name
  })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[local.azs[0]].id
  tags = merge(var.tags, {
    Name        = "${var.environment_name}-nat-gateway"
    Environment = var.environment_name
  })
  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-public-rt"
    Environment = var.environment_name
  })
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id

  }

  tags = merge(var.tags, {
    Name        = "${var.environment_name}-private-rt"
    Environment = var.environment_name
  })
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
