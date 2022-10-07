output "vpc_id" {
  value = aws_vpc.core_vpc.id
}

output "public_subnet1" {
  value = aws_subnet.pavlina_prod_byoi_public_subnet_1.id
}
output "public_subnet2" {
  value = aws_subnet.pavlina_prod_byoi_public_subnet_2.id
}

output "private_subnet_db1" {
  value = aws_subnet.pavlina_prod_byoi_private_subnet_db_1.id
}
output "private_subnet_db2" {
  value = aws_subnet.pavlina_prod_byoi_private_subnet_db_2.id
}
output "private_subnet_app1" {
  value = aws_subnet.pavlina_prod_byoi_private_subnet_app_1.id
}
output "private_subnet_app2" {
  value = aws_subnet.pavlina_prod_byoi_private_subnet_app_2.id
}
