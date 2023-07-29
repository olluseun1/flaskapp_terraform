output "app_url" {
  value = aws_lb.application_lb.dns_name
}

output "vpc_id" {
  value = aws_vpc.flask_vpc
}

output "public_subnet_1_id" {
  value = aws_subnet.public_1.id
}

output "public_subnet_2_id" {
  value = aws_subnet.public_2.id
}
output "private_subnet_1_id" {
  value = aws_subnet.private_2.id
}
output "private_subnet_2_id" {
  value = aws_subnet.private_2.id
}