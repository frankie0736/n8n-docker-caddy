#!/bin/bash

# Function to get the public IP of the server
get_public_ip() {
  curl -s ifconfig.me
}

# Function to check if domain resolves to the server's IP
check_domain_resolution() {
  local domain=$1
  local server_ip=$2
  local resolved_ip=$(ping -c 1 $domain | grep PING | awk '{print $3}' | tr -d '()')
  if [ "$resolved_ip" == "$server_ip" ]; then
    return 0
  else
    return 1
  fi
}

# Get the public IP of the server
SERVER_IP=$(get_public_ip)
echo "Your server's public IP is: $SERVER_IP"

# Prompt user for configuration details
read -p "Enter the root domain name (e.g., example.com): " DOMAIN_NAME
read -p "Enter the subdomain (e.g., n8n): " SUBDOMAIN
read -p "Enter the email for SSL certificate: " SSL_EMAIL

# Construct the full domain
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN_NAME}"

# Check if the domain resolves to the server's IP
echo "Checking if $FULL_DOMAIN resolves to $SERVER_IP..."
if ! check_domain_resolution $FULL_DOMAIN $SERVER_IP; then
  echo "Domain $FULL_DOMAIN does not resolve to $SERVER_IP. Please update your DNS settings and try again."
  exit 1
fi

# Set the data folder
DATA_FOLDER="$(pwd)/n8n-docker-caddy"

# Clone the n8n-docker-caddy repository
git clone https://github.com/frankie0736/n8n-docker-caddy.git
cd n8n-docker-caddy

# Create .env file
cat <<EOF > .env
DATA_FOLDER=${DATA_FOLDER}
DOMAIN_NAME=${DOMAIN_NAME}
SUBDOMAIN=${SUBDOMAIN}
GENERIC_TIMEZONE=Asia/Shanghai
SSL_EMAIL=${SSL_EMAIL}
EOF

# Create Caddyfile
cat <<EOF > caddy_config/Caddyfile
${FULL_DOMAIN} {
    reverse_proxy n8n:5678 {
      flush_interval -1
    }
}
EOF

# Create Docker volumes
sudo docker volume create caddy_data
sudo docker volume create n8n_data
sudo docker volume create postgres_data

# Allow necessary ports through the firewall
sudo ufw allow 80
sudo ufw allow 443

# Start Docker Compose
sudo docker compose up -d

# Enable Docker to start on boot
sudo systemctl enable docker

echo "n8n and Caddy have been successfully installed and started."
echo "You can access n8n at https://${FULL_DOMAIN}"