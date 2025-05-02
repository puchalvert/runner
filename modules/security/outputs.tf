/**
 * # Salidas del módulo de seguridad
 * 
 * Este archivo define los valores que el módulo de seguridad exporta para
 * que puedan ser utilizados por otros módulos o por el módulo principal.
 */

output "runner_sg_id" {
  description = "ID del grupo de seguridad creado para el runner"
  value       = aws_security_group.runner_sg.id
}

output "key_pair_name" {
  description = "Nombre del par de claves SSH creado"
  value       = aws_key_pair.runner_key.key_name
}

output "runner_role_arn" {
  description = "ARN del rol IAM creado para el runner"
  value       = aws_iam_role.runner_role.arn
}

output "runner_role_name" {
  description = "Nombre del rol IAM creado para el runner"
  value       = aws_iam_role.runner_role.name
}

output "runner_instance_profile_name" {
  description = "Nombre del perfil de instancia creado para el runner"
  value       = aws_iam_instance_profile.runner_profile.name
}

output "runner_instance_profile_arn" {
  description = "ARN del perfil de instancia creado para el runner"
  value       = aws_iam_instance_profile.runner_profile.arn
}