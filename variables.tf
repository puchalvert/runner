/**
 * # Variables de entrada
 * 
 * Este archivo define todas las variables que pueden ser ajustadas por el usuario
 * al aplicar la configuración Terraform. Cada variable incluye una descripción,
 * tipo, y cuando es apropiado, un valor por defecto.
 */

# Variables de configuración básica de AWS
variable "aws_region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Entorno de despliegue (dev, stage, prod)"
  type        = string
  default     = ""
}

# Variables específicas de instancia EC2
variable "instance_type" {
  description = "Tipo de instancia EC2 para el runner"
  type        = string
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t3.micro", "t3.small", "t3.medium", "t3.large", "m5.large"], var.instance_type)
    error_message = "El tipo de instancia debe ser uno de los admitidos: t2.micro, t3.micro, t3.small, t3.medium, t3.large, m5.large."
  }
}

variable "ssh_public_key_path" {
  description = "Ruta al archivo de clave pública SSH para acceder a la instancia"
  type        = string
  default     = "~/.ssh/github_runner.pub"
}

variable "ssh_ingress_cidr" {
  description = "CIDR permitido para conexiones SSH entrantes (usar con precaución)"
  type        = string
  default     = "0.0.0.0/0"  # Por defecto permite todas las IPs, considera restringir en producción
}

# Variables para configuración del GitHub Actions Runner
variable "github_repo" {
  description = "URL del repositorio de GitHub (formato: org/repo)"
  type        = string
  
  validation {
    condition     = can(regex("^[\\w-]+/[\\w-]+$", var.github_repo))
    error_message = "El formato del repositorio debe ser 'organización/repositorio'."
  }
}

variable "github_token" {
  description = "Token de acceso personal de GitHub con permisos admin:org y repo"
  type        = string
  sensitive   = true
}

variable "runner_labels" {
  description = "Etiquetas para el runner separadas por comas"
  type        = string
  default     = "self-hosted,aws,linux,x64"
}

variable "auto_install_runner" {
  description = "Si se debe instalar automáticamente el runner de GitHub Actions"
  type        = bool
  default     = true
}