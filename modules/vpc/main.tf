data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Use exactly two AZs for this VPC (first two in the region).
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Map indexes to az names: {"0" = "us-east-1a", "1" = "us-east-1b"}
  az_map = { for idx, az in local.azs : tostring(idx) => az }

  # Split CIDR into public/private ranges. Using different "newbits" and indexes.
  public_subnet_cidrs  = { for idx, az in local.az_map : idx => cidrsubnet(var.vpc_cidr, 4, tonumber(idx)) }
  private_subnet_cidrs = { for idx, az in local.az_map : idx => cidrsubnet(var.vpc_cidr, 4, tonumber(idx) + 10) }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env_name}-vpc"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env_name}-igw"
    }
  )
}

# Public subnets (one per AZ)
resource "aws_subnet" "public" {
  for_each = local.az_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.public_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                     = "${var.project_name}-${var.env_name}-public-${each.key}"
      "kubernetes.io/role/elb" = "1" # Used by Kubernetes for public LoadBalancers
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
  )
}

# Private subnets (one per AZ)
resource "aws_subnet" "private" {
  for_each = local.az_map

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.private_subnet_cidrs[each.key]
  availability_zone       = each.value
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                             = "${var.project_name}-${var.env_name}-private-${each.key}"
      "kubernetes.io/role/internal-elb" = "1" # Internal load-balancers
      "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
  )
}

# Public route table and association
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env_name}-public-rt"
    }
  )
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# NAT Gateways (1 or 2 depending on nat_gateway_count)
resource "aws_eip" "nat" {
  count      = var.nat_gateway_count
  domain     = "vpc"                     # <- this replaces vpc = true
  depends_on = [aws_internet_gateway.this]

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env_name}-nat-eip-${count.index}"
    }
  )
}


resource "aws_nat_gateway" "this" {
  count = var.nat_gateway_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[tostring(count.index)].id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env_name}-nat-${count.index}"
    }
  )
}

# Private route tables, one per private subnet
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${var.env_name}-private-rt-${each.key}"
    }
  )
}

# Each private RT routes 0.0.0.0/0 via either:
# - its AZ's NAT GW (if nat_gateway_count == 2), or
# - the first NAT GW (index 0) if nat_gateway_count == 1 to save cost.
resource "aws_route" "private_internet_access" {
  for_each = aws_route_table.private

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_count == 1 ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[tonumber(each.key)].id
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
