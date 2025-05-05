#!/bin/bash
# Script de inicialización para configurar un GitHub Actions Runner en AWS

# Habilitar el registro detallado para diagnóstico
set -x
exec > >(tee /var/log/user-data.log) 2>&1

echo "Comenzando la instalación del runner de GitHub Actions..."

# Actualizar el sistema operativo
echo "Actualizando el sistema..."
yum update -y

# Instalar herramientas y dependencias básicas
echo "Instalando paquetes necesarios..."
yum install -y \
    git \
    jq \
    curl \
    wget \
    unzip \
    zip \
    docker \
    python3 \
    python3-pip \
    amazon-cloudwatch-agent

# Configurar Docker
echo "Configurando Docker..."
systemctl enable docker
systemctl start docker

# Agregar el usuario al grupo docker
usermod -a -G docker ${runner_user}

# Instalar AWS CLI
echo "Instalando AWS CLI..."
pip3 install --upgrade awscli

# Crear directorio para el runner
echo "Creando directorio para el runner..."
mkdir -p ${install_dir}
cd ${install_dir}

# Determinar la última versión del runner
echo "Obteniendo la última versión del runner..."
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.tag_name[1:]')
echo "Última versión del runner: $RUNNER_VERSION"

# Descargar e instalar el runner
echo "Descargando el runner..."
curl -o actions-runner-linux-x64-$RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v$RUNNER_VERSION/actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

echo "Extrayendo el runner..."
tar xzf ./actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

# Limpiar el archivo descargado
rm actions-runner-linux-x64-$RUNNER_VERSION.tar.gz

# Obtener token de registro para el runner
echo "Obteniendo token de registro para el repositorio: ${github_repo}..."
RUNNER_TOKEN=$(curl -s -X POST -H "Authorization: token ${github_token}" \
  https://api.github.com/repos/${github_repo}/actions/runners/registration-token | jq -r .token)

# Verificar que se obtuvo el token
if [ -z "$RUNNER_TOKEN" ] || [ "$RUNNER_TOKEN" == "null" ]; then
  echo "Error: No se pudo obtener el token de registro. Verifique el token de GitHub y los permisos del repositorio."
  exit 1
fi

# Configurar el runner con las etiquetas especificadas
echo "Configurando el runner con etiquetas: ${runner_labels}..."
./config.sh --url https://github.com/${github_repo} \
            --token $RUNNER_TOKEN \
            --name "${runner_name}" \
            --labels "${runner_labels}" \
            --unattended \
            --replace

# Instalar el runner como servicio
echo "Instalando el runner como servicio..."
./svc.sh install

# Iniciar el servicio del runner
echo "Iniciando el servicio del runner..."
./svc.sh start

# Configurar permisos
echo "Configurando permisos..."
chown -R ${runner_user}:${runner_group} ${install_dir}

# Instalar herramientas adicionales comunes para CI/CD
echo "Instalando herramientas adicionales para CI/CD..."

# Node.js
echo "Instalando Node.js..."
curl -sL https://rpm.nodesource.com/setup_16.x | bash -
yum install -y nodejs

# Instalar Maven
echo "Instalando Maven..."
yum install -y maven

# Instalación de Docker Compose
echo "Instalando Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Instalar Terraform
echo "Instalando Terraform..."
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum install -y terraform

# Configurar CloudWatch Agent para monitoreo
echo "Configurando CloudWatch Agent..."
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<EOF
{
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "resources": [
          "*"
        ],
        "totalcpu": true
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ]
      },
      "disk": {
        "measurement": [
          "disk_used_percent"
        ],
        "resources": [
          "/"
        ]
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/user-data.log",
            "log_group_name": "/ec2/github-runner/user-data",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "${install_dir}/_diag/Runner_*.log",
            "log_group_name": "/ec2/github-runner/runner-logs",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Iniciar CloudWatch Agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

echo "Instalación del runner completada con éxito."