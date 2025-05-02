/**
 * # Salidas del módulo del runner
 * 
 * Este archivo define los valores que el módulo del runner exporta para
 * que puedan ser utilizados por otros módulos o por el módulo principal.
 */

output "instance_id" {
  description = "ID de la instancia EC2 del runner"
  value       = aws_instance.github_runner.id
}

output "public_ip" {
  description = "Dirección IP pública de la instancia del runner"
  value       = aws_instance.github_runner.public_ip
}

output "private_ip" {
  description = "Dirección IP privada de la instancia del runner"
  value       = aws_instance.github_runner.private_ip
}

output "instance_state" {
  description = "Estado actual de la instancia del runner"
  value       = aws_instance.github_runner.instance_state
}

output "availability_zone" {
  description = "Zona de disponibilidad donde se lanzó la instancia"
  value       = aws_instance.github_runner.availability_zone
}

output "data_volume_id" {
  description = "ID del volumen de datos adicional (si existe)"
  value       = var.data_volume_size > 0 ? aws_ebs_volume.runner_data[0].id : null
}

output "ami_id" {
  description = "ID de la AMI utilizada para la instancia"
  value       = aws_instance.github_runner.ami
}

output "instance_type" {
  description = "Tipo de instancia EC2 utilizado"
  value       = aws_instance.github_runner.instance_type
}