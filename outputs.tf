/**
 * # Salidas del proyecto
 * 
 * Este archivo define todas las salidas que se mostrarán después de aplicar
 * la configuración de Terraform. Estas salidas proporcionan información útil
 * sobre los recursos creados.
 */

output "runner_instance_id" {
  description = "ID de la instancia EC2 del runner"
  value       = module.runner.instance_id
}

output "runner_public_ip" {
  description = "Dirección IP pública del runner"
  value       = module.runner.public_ip
}

output "runner_instance_state" {
  description = "Estado actual de la instancia del runner"
  value       = module.runner.instance_state
}

output "ssh_command" {
  description = "Comando SSH para conectarse al runner"
  value       = "ssh -i ${pathexpand(replace(var.ssh_public_key_path, ".pub", ""))} ${local.runner.runner_user}@${module.runner.public_ip}"
}

output "runner_status_check" {
  description = "Comando para verificar el estado del servicio del runner en la instancia"
  value       = "ssh -i ${pathexpand(replace(var.ssh_public_key_path, ".pub", ""))} ${local.runner.runner_user}@${module.runner.public_ip} 'sudo systemctl status actions.runner'"
}

output "vpc_id" {
  description = "ID de la VPC creada"
  value       = module.network.vpc_id
}

output "subnet_id" {
  description = "ID de la subred creada"
  value       = module.network.subnet_id
}

output "security_group_id" {
  description = "ID del grupo de seguridad creado para el runner"
  value       = module.security.runner_sg_id
}

output "github_repository" {
  description = "Repositorio de GitHub asociado con este runner"
  value       = var.github_repo
}

output "runner_labels" {
  description = "Etiquetas configuradas para este runner"
  value       = var.runner_labels
}