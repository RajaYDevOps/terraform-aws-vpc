resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
    local.common_tags
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.common_tags
  )
}

# us-east-1a and us-east-1b
# roboshop-dev-public-1a, robsohsop-dev-public-1b
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index] # us-east-1a
  map_public_ip_on_launch = "true"

  tags = merge(
    var.public_subnet_tags,
    local.common_tags,
  {
    #need to understand how the split function worked below
    Name = "${local.common_name}-public-${split("-",local.az_names[count.index])[2]}"
  }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index] # us-east-1a
  map_public_ip_on_launch = "false"

  tags = merge(
    var.private_subnet_tags,
    local.common_tags,
  {
    #need to understand how the split function worked below
    Name = "${local.common_name}-private-${split("-",local.az_names[count.index])[2]}"
  }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone = local.az_names[count.index] # us-east-1a
  map_public_ip_on_launch = "false"

  tags = merge(
    var.database_subnet_tags,
    local.common_tags,
  {
    #need to understand how the split function worked below
    Name = "${local.common_name}-database-${split("-",local.az_names[count.index])[2]}"
  }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.public_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-public"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.private_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-private"
    }
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge (
    var.database_route_table_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-database"
    }
  )
}