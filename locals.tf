/**
 * # Variables locales
 * 
 * Este archivo contiene todas las variables locales usadas en el proyecto.
 * Las variables locales nos permiten:
 * - Centralizar configuraciones comunes
 * - Derivar valores a partir de variables de entrada
 * - Definir valores por defecto más complejos
 * - Organizar valores relacionados en estructuras
 */

locals {
  # Nombre base del proyecto usado para nombrar recursos
  project_name = "github-runner"
  
  # Variables relacionadas con el entorno y etiquetas
  environment = var.environment != "" ? var.environment : terraform.workspace
  
  # Tags comunes para todos los recursos
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    GitHubRepo  = var.github_repo
    CreatedAt   = timestamp()
  }

  # Configuración de la red
  network = {
    vpc_cidr    = "10.0.0.0/16"
    subnet_cidr = "10.0.1.0/24"
  }
  
  # Configuración específica del runner
  runner = {
    # ID de AMI personalizada (si se deja vacío, se usará la AMI de Amazon Linux 2 más reciente)
    ami_id = ""
    
    # Usuario y grupo para el runner
    runner_user = "ec2-user"
    runner_group = "ec2-user"
    
    # Tamaño del volumen raíz en GB
    root_volume_size = 30
    
    # Directorio de instalación del runner
    install_dir = "/home/ec2-user/actions-runner"
  }
  
  # Herramientas y paquetes a instalar en el runner
  runner_packages = {
    basic = [
      "git",
      "jq",
      "curl",
      "wget",
      "unzip",
      "zip"
    ]
    
    development = [
      "docker",
      "python3",
      "python3-pip",
      "gcc",
      "make"
    ]
    
    monitoring = [
      "amazon-cloudwatch-agent"
    ]
  }
  
  # Script de instalación del runner con explicaciones detalladas
  runner_install_script = var.auto_install_runner ? templatefile("${path.module}/modules/runner/templates/user_data.sh", {
    github_repo   = var.github_repo
    github_token  = var.github_token
    runner_labels = var.runner_labels
    runner_name   = "${local.project_name}-$(hostname)"
    install_dir   = local.runner.install_dir
    runner_user   = local.runner.runner_user
    runner_group  = local.runner.runner_group
    # Paquetes a instalar formateados para el comando yum
    packages      = concat(local.runner_packages.basic, local.runner_packages.development, local.runner_packages.monitoring)
  }) : ""
}