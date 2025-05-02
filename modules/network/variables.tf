/**
 * # Variables del módulo de red
 * 
 * Este archivo define las variables específicas necesarias para configurar
 * los recursos de red para el runner de GitHub Actions.
 */

variable "vpc_cidr" {
  description = "Bloque CIDR para la VPC (rango de direcciones IP)"
  type        = string
  default     = "10.0.0.0/16"
  
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "El valor de vpc_cidr debe ser un bloque CIDR válido."
  }
}

variable "subnet_cidr" {
  description = "Bloque CIDR para la subred pública (debe ser un subconjunto de vpc_cidr)"
  type        = string
  default     = "10.0.1.0/24"
  
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "El valor de subnet_cidr debe ser un bloque CIDR válido."
  }
}

variable "availability_zone" {
  description = "Zona de disponibilidad donde se creará la subred"
  type        = string
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetar recursos"
  type        = string
  default     = "github-runner"
}