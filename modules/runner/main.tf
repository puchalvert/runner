/**
 * # Módulo del Runner de GitHub Actions
 * 
 * Este módulo gestiona la instancia EC2 que ejecutará el runner de GitHub Actions y
 * su configuración. Se encarga de:
 * - Crear la instancia EC2
 * - Proporcionar el script de inicialización (user_data)
 * - Configurar el almacenamiento y las etiquetas
 * 
 * El propósito es tener un runner totalmente funcional que se registre automáticamente
 * con el repositorio GitHub especificado.
 */

# Instancia EC2 para el runner de GitHub Actions
resource "aws_instance" "github_runner" {
  # AMI (Amazon Machine Image) a utilizar
  ami = var.ami_id
  
  # Tipo de instancia que determina los recursos de CPU, memoria, red, etc.
  instance_type = var.instance_type
  
  # Nombre del par de claves para acceso SSH
  key_name = var.key_name
  
  # Subred donde se lanzará la instancia
  subnet_id = var.subnet_id
  
  # Grupos de seguridad que controlan el tráfico de red
  vpc_security_group_ids = var.security_group_ids
  
  # Perfil de instancia que proporciona permisos IAM
  iam_instance_profile = var.iam_instance_profile
  
  # Script de inicialización que se ejecuta al lanzar la instancia
  # Si auto_install_runner es falso, el script será mínimo
  user_data = var.auto_install_runner ? templatefile("${path.module}/templates/user_data.sh.tpl", {
    github_repo   = var.github_repo
    github_token  = var.github_token
    runner_labels = var.runner_labels
    runner_name   = "${var.project_name}-$(hostname)"
    install_dir   = "/home/${var.runner_user}/actions-runner"
    runner_user   = var.runner_user
    runner_group  = var.runner_group
  }) : <<-EOF
    #!/bin/bash
    echo "Runner en modo de configuración manual. El runner debe ser configurado manualmente."
    # Actualización básica del sistema
    yum update -y
    EOF

  # Configuración del volumen raíz
  root_block_device {
    # Tamaño del volumen en GB
    volume_size = var.root_volume_size
    
    # Tipo de volumen (gp3 ofrece buen rendimiento a menor costo)
    volume_type = "gp3"
    
    # Eliminar el volumen al terminar la instancia
    delete_on_termination = true
    
    # Cifrado del volumen
    encrypted = true
    
    # IOPS aprovisionadas para el volumen gp3
    iops = 3000
    
    # Rendimiento de transferencia en MiB/s para gp3
    throughput = 125
    
    tags = {
      Name = "${var.project_name}-root-volume"
    }
  }

  # Opciones de monitoreo detallado de CloudWatch
  monitoring = true
  
  # Control de apagado, por defecto termina la instancia
  instance_initiated_shutdown_behavior = "terminate"

  # Etiquetas para la instancia
  tags = {
    Name = "${var.project_name}-instance"
    Role = "GitHub Actions Runner"
    Repository = var.github_repo
    Labels = var.runner_labels
  }
  
  # Esperar a que la instancia esté disponible antes de continuar
  lifecycle {
    create_before_destroy = true
  }
}

# Volumen EBS adicional opcional para almacenamiento de datos del runner
resource "aws_ebs_volume" "runner_data" {
  # Solo crear este volumen si data_volume_size es mayor que 0
  count = var.data_volume_size > 0 ? 1 : 0
  
  # Zona de disponibilidad que debe coincidir con la instancia
  availability_zone = aws_instance.github_runner.availability_zone
  
  # Tamaño del volumen en GB
  size = var.data_volume_size
  
  # Tipo de volumen
  type = "gp3"
  
  # Cifrado del volumen
  encrypted = true
  
  tags = {
    Name = "${var.project_name}-data-volume"
  }
}

# Adjuntar el volumen EBS adicional a la instancia si existe
resource "aws_volume_attachment" "runner_data_attachment" {
  # Solo crear si hay un volumen de datos
  count = var.data_volume_size > 0 ? 1 : 0
  
  # Nombre del dispositivo dentro del sistema operativo
  device_name = "/dev/sdf"
  
  # ID del volumen a adjuntar
  volume_id = aws_ebs_volume.runner_data[0].id
  
  # ID de la instancia a la que adjuntar el volumen
  instance_id = aws_instance.github_runner.id
  
  # Forzar desconexión al borrar
  stop_instance_before_detaching = true
}