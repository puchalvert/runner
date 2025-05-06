/**
 * # Módulo de red
 * 
 * Este módulo gestiona todos los recursos de red necesarios para el runner de GitHub Actions:
 * - VPC (Red Virtual Privada)
 * - Subred pública
 * - Internet Gateway
 * - Tabla de rutas
 * 
 * El propósito es proporcionar un entorno de red aislado pero con acceso a internet
 * para que el runner pueda comunicarse con GitHub y otros servicios.
 */

# VPC principal para el runner
# Una VPC es un recurso que proporciona una red virtual aislada en la nube de AWS
resource "aws_vpc" "runner_vpc" {
  # Bloque CIDR que define el rango de direcciones IP para la VPC
  cidr_block = var.vpc_cidr
  
  # Habilita los nombres de host DNS para instancias en esta VPC
  enable_dns_hostnames = true
  
  # Habilita la resolución DNS dentro de la VPC
  enable_dns_support = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc"
  }
  )
}

# Subred pública dentro de la VPC
# Una subred es una división de la VPC con su propio rango de direcciones IP
resource "aws_subnet" "runner_subnet" {
  # VPC a la que pertenece esta subred
  vpc_id = aws_vpc.runner_vpc.id
  
  # Rango de direcciones IP para esta subred, debe ser un subconjunto del rango de la VPC
  cidr_block = var.subnet_cidr
  
  # Asigna automáticamente direcciones IP públicas a las instancias lanzadas en esta subred
  map_public_ip_on_launch = true
  
  # Zona de disponibilidad donde se ubicará esta subred
  availability_zone = var.availability_zone

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-subnet"
  }
  )
}

# Internet Gateway para permitir comunicación entre la VPC e Internet
# Este recurso permite que las instancias en la VPC se comuniquen con Internet
resource "aws_internet_gateway" "runner_igw" {
  # VPC a la que se conectará este Internet Gateway
  vpc_id = aws_vpc.runner_vpc.id

  tags = merge (var.common_tags, {
    Name = "${var.project_name}-igw"
  }
  )
}

# Tabla de rutas para dirigir el tráfico de red
# Define cómo se enruta el tráfico desde las subredes
resource "aws_route_table" "runner_rtb" {
  # VPC a la que pertenece esta tabla de rutas
  vpc_id = aws_vpc.runner_vpc.id

  # Ruta predeterminada que envía todo el tráfico saliente a Internet a través del Internet Gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.runner_igw.id
  }

  tags = merge (var.common_tags, {
    Name = "${var.project_name}-rtb"
  }
  )
}

# Asociación entre la subred y la tabla de rutas
# Este recurso vincula una tabla de rutas específica con una subred para determinar su comportamiento de enrutamiento
resource "aws_route_table_association" "runner_rta" {
  # ID de la subred a asociar
  subnet_id = aws_subnet.runner_subnet.id
  
  # ID de la tabla de rutas a asociar con la subred
  route_table_id = aws_route_table.runner_rtb.id
}