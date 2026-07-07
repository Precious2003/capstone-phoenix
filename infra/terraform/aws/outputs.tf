output "vpc_id" {
  value = aws_vpc.lab.id
}

output "mgmt_sg_id" {
  value = aws_security_group.mgmt.id
}
