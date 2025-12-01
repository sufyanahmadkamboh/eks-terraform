output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets."
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  description = "IDs of private subnets."
  value       = [for s in aws_subnet.private : s.id]
}

output "azs" {
  description = "Availability Zones used by this VPC."
  value       = [for az in local.azs : az]
}
