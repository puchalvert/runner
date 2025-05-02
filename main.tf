/**
 * # GitHub Actions Runner en AWS
 * 
 * Este módulo principal organiza y conecta todos los componentes necesarios para
 * desplegar un runner de GitHub Actions autogestionado en AWS.
 * 
 * ## Componentes
 * - Módulo de red: Crea la VPC, subredes, y configuración de red
 * - Módulo de seguridad: Configura grupos de seguridad, IAM y políticas
 * - Módulo de runner: Despliega la instancia EC2 que ejecutará el runner
 */

# Configuración del proveedor de AWS
provider "aws" {
  region = var.aws_region
  
  # Recomendado: añadir tags por defecto para todos los recursos
  default_tags {
    tags = local.common_tags
  }
}

# Módulo de red: Crea la infraestructura de red necesaria
module "network" {
  source = "./modules/network"
  
  vpc_cidr           = local.network.vpc_cidr
  subnet_cidr        = local.network.subnet_cidr
  availability_zone  = "${var.aws_region}a"
  project_name       = local.project_name
}

# Módulo de seguridad: Gestiona IAM, grupos de seguridad y accesos
module "security" {
  source = "./modules/security"
  
  vpc_id             = module.network.vpc_id
  project_name       = local.project_name
  ssh_public_key     = file(var.ssh_public_key_path)
  ssh_ingress_cidr   = var.ssh_ingress_cidr
}

# Módulo runner: Crea la instancia EC2 y configura el GitHub Actions runner
module "runner" {
  source = "./modules/runner"
  
  ami_id             = local.runner.ami_id != "" ? local.runner.ami_id : data.aws_ami.amazon_linux[0].id
  instance_type      = var.instance_type
  subnet_id          = module.network.subnet_id
  security_group_ids = [module.security.runner_sg_id]
  key_name           = module.security.key_pair_name
  iam_instance_profile = module.security.runner_instance_profile_name

  # Variables específicas del runner de GitHub
  github_repo        = var.github_repo
  github_token       = var.github_token
  runner_labels      = var.runner_labels
  
  # Variable para controlar la instalación automática del runner
  auto_install_runner = var.auto_install_runner
  
  # Variables opcionales para personalización
  runner_user        = local.runner.runner_user
  runner_group       = local.runner.runner_group
  root_volume_size   = local.runner.root_volume_size
  
  # Para obtener el nombre único del runner
  project_name       = local.project_name
}

# Obtener la AMI de Amazon Linux 2 más reciente si no se especifica una
data "aws_ami" "amazon_linux" {
  count       = local.runner.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}