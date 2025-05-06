/**
 * # Variables del módulo del runner
 * 
 * Este archivo define las variables específicas necesarias para configurar
 * la instancia EC2 que ejecutará el runner de GitHub Actions.
 */

# Variables de configuración de instancia EC2
variable "ami_id" {
  description = "ID de la AMI a utilizar para la instancia del runner"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el runner"
  type        = string
}

variable "subnet_id" {
  description = "ID de la subred donde se lanzará la instancia"
  type        = string
}

variable "security_group_ids" {
  description = "Lista de IDs de grupos de seguridad a asociar con la instancia"
  type        = list(string)
}

variable "key_name" {
  description = "Nombre del par de claves SSH para acceder a la instancia"
  type        = string
}

variable "iam_instance_profile" {
  description = "Nombre del perfil de instancia IAM a asociar"
  type        = string
}

variable "root_volume_size" {
  description = "Tamaño del volumen raíz en GB"
  type        = number
  default     = 30
}

variable "data_volume_size" {
  description = "Tamaño del volumen de datos adicional en GB (0 para no crear)"
  type        = number
  default     = 0
}

variable "project_name" {
  description = "Nombre del proyecto para etiquetar recursos"
  type        = string
}

# Variables específicas del runner de GitHub
variable "github_repo" {
  description = "URL del repositorio de GitHub (formato: org/repo)"
  type        = string
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

variable "runner_user" {
  description = "Usuario del sistema operativo que ejecutará el runner"
  type        = string
  default     = "ec2-user"
}

variable "runner_group" {
  description = "Grupo del sistema operativo para el runner"
  type        = string
  default     = "ec2-user"
}

variable "common_tags" {
  description = "Etiquetas comunes para todos los recursos"
  type        = map(string)
  default     = {}
}

