/**
 * # Módulo de seguridad
 * 
 * Este módulo gestiona todos los recursos relacionados con la seguridad:
 * - Grupos de seguridad (firewall virtual)
 * - Pares de claves SSH
 * - Roles IAM y perfiles de instancia
 * - Políticas de permisos
 * 
 * El objetivo es garantizar que el runner tenga los permisos adecuados
 * mientras mantiene el principio de privilegio mínimo.
 */

# Grupo de seguridad para el runner
# Un grupo de seguridad actúa como un firewall virtual que controla el tráfico
resource "aws_security_group" "runner_sg" {
  name        = "${var.project_name}-sg"
  description = "Grupo de seguridad para el runner de GitHub Actions"
  vpc_id      = var.vpc_id

  # Regla de entrada para permitir SSH (puerto 22)
  # Esta regla permite la conexión remota al servidor para administración
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_ingress_cidr]
    description = "Acceso SSH para administración"
  }

  # Regla de salida para permitir todo el tráfico saliente
  # El runner necesita poder conectarse a GitHub, AWS y otros servicios
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Cualquier protocolo
    cidr_blocks = ["0.0.0.0/0"]
    description = "Permite todo el tráfico saliente"
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# Par de claves SSH para acceder a la instancia
# Este par de claves permite el acceso seguro por SSH a la instancia del runner
resource "aws_key_pair" "runner_key" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "${var.project_name}-key"
  }
}

# Rol IAM para el runner
# Un rol IAM define los permisos de un servicio o recurso de AWS
resource "aws_iam_role" "runner_role" {
  name = "${var.project_name}_role"

  # Política de confianza que permite que el servicio EC2 asuma este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-role"
  }
}

# Política base para el runner
# Esta política define los permisos específicos que tiene el runner en AWS
resource "aws_iam_role_policy" "runner_policy" {
  name = "${var.project_name}_policy"
  role = aws_iam_role.runner_role.id

  # Política JSON que define los permisos
  # El runner tiene permisos para describir recursos EC2, acceder a S3 y ECR
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        # Permisos para describir recursos EC2
        Action = [
          "ec2:Describe*",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # Permisos para listar y acceder a objetos en S3
        Action = [
          "s3:List*",
          "s3:Get*",
          "s3:Put*",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        # Permisos para acceder a imágenes de contenedores en ECR
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Política para permitir al runner publicar métricas a CloudWatch
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name = "${var.project_name}_cloudwatch_policy"
  role = aws_iam_role.runner_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

# Perfil de instancia para asociar el rol IAM a la instancia EC2
# Un perfil de instancia es un contenedor para un rol IAM que permite pasar el rol a una instancia EC2
resource "aws_iam_instance_profile" "runner_profile" {
  name = "${var.project_name}_profile"
  role = aws_iam_role.runner_role.name
}