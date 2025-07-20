#!/usr/bin/env bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

CERTS_DIR="$(pwd)/.certs"
CA_DIR="$CERTS_DIR/ca"
SERVICES_NAMES=("account")

############################################## FUNÇÕES DE GERAÇÃO DE CONFIGS OPENSSL

generate_openssl_conf_server() {
  local path="$1"
  cat > "$path/server_openssl.cnf" <<EOF
[ req ]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[ req_distinguished_name ]
countryName_default = BR
stateOrProvinceName_default = Paraiba
localityName_default = CampinaGrande
organizationName_default = Barbershop Service
commonName_default = Barbershop

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = api.localhost
EOF
}

generate_openssl_conf_server_ext() {
  local path="$1"
  cat > "$path/server_ext.cnf" <<EOF
basicConstraints = CA:false
keyUsage         = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName   = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = api.localhost
EOF
}

generate_openssl_conf_mongodb_client() {
  local path="$1"
  local service="$2"
  cat > "$path/mongodb_client_openssl.cnf" <<EOF
[ req ]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[ req_distinguished_name ]
countryName_default = BR
stateOrProvinceName_default = Paraiba
localityName_default = CampinaGrande
organizationName_default = Barbershop Service
commonName_default = Barbershop

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = mongodb
DNS.3 = $service
EOF
}

generate_openssl_conf_client_ext() {
  local path="$1"
  local service="$2"
  cat > "$path/client_ext.cnf" <<EOF
basicConstraints = CA:false
keyUsage         = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName   = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = mongodb
DNS.3 = $service
EOF
}

############################################## 1 - CERTIFICATE AUTHORITY (CA)

mkdir -p "$CA_DIR"

log_info "[1/5] Gerando chave privada da CA..."
openssl genrsa -out "$CA_DIR/ca_key.pem" 4096

log_info "[1/5] Gerando certificado da CA (autoassinado)..."
openssl req -x509 -new -nodes -key "$CA_DIR/ca_key.pem" -sha256 -days 365 \
  -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=Barbershop/CN=Barbershop CA" \
  -out "$CA_DIR/ca_cert.pem"

log_success "--CERTIFICATE AUTHORITY GERADA--"

############################################## 2 - SERVIÇOS

generate_openssl_conf_server "$CERTS_DIR"
generate_openssl_conf_server_ext "$CERTS_DIR"

for service in "${SERVICES_NAMES[@]}"; do
    SERVICE_DIR="$CERTS_DIR/$service"
    mkdir -p "$SERVICE_DIR"

    echo ""
    echo "$service" | tr '[:lower:]' '[:upper:]'
    log_info "[2/5] Gerando chave privada para: $service"
    openssl genrsa -out "$SERVICE_DIR/server_key.pem" 2048

    log_info "[2/5] Gerando CSR (Certificate Signing Request) para: $service"
    openssl req -new -key "$SERVICE_DIR/server_key.pem" \
    -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=${service}/CN=Barbershop" \
    -out "$SERVICE_DIR/$service.csr" \
    -config "$CERTS_DIR/server_openssl.cnf"

    log_info "[2/5] Assinando certificado para: $service"
    openssl x509 -req -in "$SERVICE_DIR/$service.csr" \
    -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
    -CAcreateserial -out "$SERVICE_DIR/server_cert.pem" \
    -days 3650 -sha256 \
    -extfile "$CERTS_DIR/server_ext.cnf"

    log_success "--CERTIFICADO DE SERVIDOR PARA $service GERADO--"

    ######################################################## MONGODB CLIENT CERTS

    log_info "[2/5] Gerando chave privada MongoDb para: $service"
    openssl genrsa -out "$SERVICE_DIR/mongodb_key.pem" 2048

    generate_openssl_conf_mongodb_client "$SERVICE_DIR" "$service"

    log_info "[2/5] Gerando CSR (Certificate Signing Request) MongoDb para: $service"
    openssl req -new -key "$SERVICE_DIR/mongodb_key.pem" \
    -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=${service}/CN=Barbershop" \
    -out "$SERVICE_DIR/mongodb_client.csr" \
    -config "$SERVICE_DIR/mongodb_client_openssl.cnf"

    generate_openssl_conf_client_ext "$SERVICE_DIR" "$service"

    log_info "[2/5] Assinando certificado de cliente MongoDb para: $service"
    openssl x509 -req -in "$SERVICE_DIR/mongodb_client.csr" \
    -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
    -CAcreateserial -out "$SERVICE_DIR/mongodb_client_cert.pem" \
    -days 365 -sha256 \
    -extfile "$SERVICE_DIR/client_ext.cnf"

    log_success "--CERTIFICADO DE CLIENTE MONGODB PARA $service GERADO--"

    ######################################################## MONGODB CLIENT CERTS

    
done
