/**
 * # Variables del módulo de seguridad
 * 
 * Este archivo define las variables necesarias para configurar los aspectos
 * de seguridad del runner de GitHub Actions, como acceso SSH, grupos de
 * seguridad y permisos IAM.
 */

variable "vpc_id" {
  description = "ID de la VPC donde se crearán los recursos de seguridad"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetar recursos"
  type        = string
}

variable "ssh_public_key" {
  description = "Clave pública SSH para acceder a la instancia EC2"
  type        = string
}

variable "ssh_ingress_cidr" {
  description = "Bloque CIDR permitido para conexiones SSH entrantes"
  type        = string
  default     = "0.0.0.0/0"
}

variable "additional_iam_policies" {
  description = "ARNs de políticas IAM adicionales para adjuntar al rol del runner"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Etiquetas comunes para todos los recursos"
  type        = map(string)
  default     = {}
}