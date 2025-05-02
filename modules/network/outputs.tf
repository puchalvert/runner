/**
 * # Salidas del módulo de red
 * 
 * Este archivo define los valores que el módulo de red exporta para
 * que puedan ser utilizados por otros módulos o por el módulo principal.
 */

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.runner_vpc.id
}

output "subnet_id" {
  description = "ID de la subred pública creada"
  value       = aws_subnet.runner_subnet.id
}

output "internet_gateway_id" {
  description = "ID del Internet Gateway creado"
  value       = aws_internet_gateway.runner_igw.id
}

output "route_table_id" {
  description = "ID de la tabla de rutas creada"
  value       = aws_route_table.runner_rtb.id
}

output "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  value       = aws_vpc.runner_vpc.cidr_block
}

output "subnet_cidr" {
  description = "Bloque CIDR de la subred"
  value       = aws_subnet.runner_subnet.cidr_block
}

output "availability_zone" {
  description = "Zona de disponibilidad de la subred"
  value       = aws_subnet.runner_subnet.availability_zone
}