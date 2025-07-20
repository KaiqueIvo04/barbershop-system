#!/usr/bin/env bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

CERTS_DIR="$(pwd)/.certs"
CA_DIR="$CERTS_DIR/ca"
SERVICES_NAMES=("api-gtw" "account" "schedule-management")
SERVER_SERVICES=("mongodb" "rabbitmq")

source ./openssl_config_functions.sh

############################################## 1 - CERTIFICATE AUTHORITY (CA)

mkdir -p "$CA_DIR"

log_info "[1/5] Gerando chave privada da CA..."
openssl genrsa -out "$CA_DIR/ca_key.pem" 4096

log_info "[1/5] Gerando certificado da CA (autoassinado)..."
openssl req -x509 -new -nodes -key "$CA_DIR/ca_key.pem" -sha256 -days 365 \
  -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=Barbershop/CN=Barbershop CA" \
  -out "$CA_DIR/ca_cert.pem"

log_success "--CERTIFICATE AUTHORITY GERADA--"

############################################## 2 - SERVER SERVICES (MongoDB & RabbitMQ)

for server_service in "${SERVER_SERVICES[@]}"; do
    SERVER_DIR="$CERTS_DIR/$server_service"
    mkdir -p "$SERVER_DIR"

    echo ""
    echo "$server_service SERVER" | tr '[:lower:]' '[:upper:]'
    
    if [ "$server_service" = "mongodb" ]; then
        log_info "[2/5] Gerando chave privada para MongoDB Server"
        openssl genrsa -out "$SERVER_DIR/server_key.pem" 2048

        generate_openssl_conf_mongodb_server "$SERVER_DIR"

        log_info "[2/5] Gerando CSR para MongoDB Server"
        openssl req -new -key "$SERVER_DIR/server_key.pem" \
        -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=MongoDB/CN=mongodb" \
        -out "$SERVER_DIR/server.csr" \
        -config "$SERVER_DIR/mongodb_server_openssl.cnf"

        generate_openssl_conf_mongodb_server_ext "$SERVER_DIR"

        log_info "[2/5] Assinando certificado para MongoDB Server"
        openssl x509 -req -in "$SERVER_DIR/server.csr" \
        -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
        -CAcreateserial -out "$SERVER_DIR/server_cert.pem" \
        -days 3650 -sha256 \
        -extfile "$SERVER_DIR/mongodb_server_ext.cnf"

        # Concat certificate with key for mongodb
        cat "$SERVER_DIR/server_cert.pem" "$SERVER_DIR/server_key.pem" >"$SERVER_DIR/server.pem"
        rm -f "$SERVER_DIR/server_cert.pem" "$SERVER_DIR/server_key.pem"

        # Copy CA for mongodb server
        cp "$CA_DIR/ca_cert.pem" "$SERVER_DIR/"

        log_success "--CERTIFICADO DE SERVIDOR MONGODB GERADO--"

    elif [ "$server_service" = "rabbitmq" ]; then
        log_info "[2/5] Gerando chave privada para RabbitMQ Server"
        openssl genrsa -out "$SERVER_DIR/server_key.pem" 2048

        generate_openssl_conf_rabbitmq_server "$SERVER_DIR"

        log_info "[2/5] Gerando CSR para RabbitMQ Server"
        openssl req -new -key "$SERVER_DIR/server_key.pem" \
        -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=RabbitMQ/CN=rabbitmq" \
        -out "$SERVER_DIR/server.csr" \
        -config "$SERVER_DIR/rabbitmq_server_openssl.cnf"

        generate_openssl_conf_rabbitmq_server_ext "$SERVER_DIR"

        log_info "[2/5] Assinando certificado para RabbitMQ Server"
        openssl x509 -req -in "$SERVER_DIR/server.csr" \
        -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
        -CAcreateserial -out "$SERVER_DIR/server_cert.pem" \
        -days 3650 -sha256 \
        -extfile "$SERVER_DIR/rabbitmq_server_ext.cnf"

        # Copy CA for rabbitmq
        cp "$CA_DIR/ca_cert.pem" "$SERVER_DIR/"

        log_success "--CERTIFICADO DE SERVIDOR RABBITMQ GERADO--"
    fi
done

############################################## 3 - SERVICES

generate_openssl_conf_server "$CERTS_DIR"
generate_openssl_conf_server_ext "$CERTS_DIR"

for service in "${SERVICES_NAMES[@]}"; do
    SERVICE_DIR="$CERTS_DIR/$service"
    mkdir -p "$SERVICE_DIR"

    echo ""
    echo "$service" | tr '[:lower:]' '[:upper:]'
    log_info "[3/5] Gerando chave privada para: $service"
    openssl genrsa -out "$SERVICE_DIR/server_key.pem" 2048

    log_info "[3/5] Gerando CSR (Certificate Signing Request) para: $service"
    openssl req -new -key "$SERVICE_DIR/server_key.pem" \
    -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=${service}/CN=Barbershop" \
    -out "$SERVICE_DIR/$service.csr" \
    -config "$CERTS_DIR/server_openssl.cnf"

    log_info "[3/5] Assinando certificado para: $service"
    openssl x509 -req -in "$SERVICE_DIR/$service.csr" \
    -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
    -CAcreateserial -out "$SERVICE_DIR/server_cert.pem" \
    -days 3650 -sha256 \
    -extfile "$CERTS_DIR/server_ext.cnf"

    log_success "--CERTIFICADO DE SERVIDOR PARA $service GERADO--"

    ######################################################## MONGODB CLIENT CERTS

    log_info "[3/5] Gerando chave privada MongoDb para: $service"
    openssl genrsa -out "$SERVICE_DIR/mongodb_key.pem" 2048

    generate_openssl_conf_mongodb_client "$SERVICE_DIR" "$service"

    log_info "[3/5] Gerando CSR (Certificate Signing Request) MongoDb para: $service"
    openssl req -new -key "$SERVICE_DIR/mongodb_key.pem" \
    -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=${service}/CN=Barbershop" \
    -out "$SERVICE_DIR/mongodb_client.csr" \
    -config "$SERVICE_DIR/mongodb_client_openssl.cnf"

    generate_openssl_conf_mongodb_client_ext "$SERVICE_DIR" "$service"

    log_info "[3/5] Assinando certificado de cliente MongoDb para: $service"
    openssl x509 -req -in "$SERVICE_DIR/mongodb_client.csr" \
    -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
    -CAcreateserial -out "$SERVICE_DIR/mongodb_client_cert.pem" \
    -days 365 -sha256 \
    -extfile "$SERVICE_DIR/client_ext.cnf"

    # Concat certificate with key for mongodb
    cat "$SERVICE_DIR/mongodb_client_cert.pem" "$SERVICE_DIR/mongodb_key.pem" >"$SERVICE_DIR/mongodb.pem"
    rm -f "$SERVICE_DIR/mongodb_client_cert.pem" "$SERVICE_DIR/mongodb_key.pem"

    # Copy CA for mongodb client
    cp "$CA_DIR/ca_cert.pem" "$SERVICE_DIR/"

    log_success "--CERTIFICADO DE CLIENTE MONGODB PARA $service GERADO--"

    ######################################################## RABBITMQ CLIENT CERTS

    log_info "[3/5] Gerando chave privada RabbitMQ para: $service"
    openssl genrsa -out "$SERVICE_DIR/rabbitmq_key.pem" 2048

    generate_openssl_conf_rabbitmq_client "$SERVICE_DIR" "$service"

    log_info "[3/5] Gerando CSR (Certificate Signing Request) RabbitMQ para: $service"
    openssl req -new -key "$SERVICE_DIR/rabbitmq_key.pem" \
    -subj "/C=BR/ST=Paraiba/L=CampinaGrande/O=${service}/CN=Barbershop" \
    -out "$SERVICE_DIR/rabbitmq_client.csr" \
    -config "$SERVICE_DIR/rabbitmq_client_openssl.cnf"

    generate_openssl_conf_rabbitmq_client_ext "$SERVICE_DIR" "$service"

    log_info "[3/5] Assinando certificado de cliente RabbitMQ para: $service"
    openssl x509 -req -in "$SERVICE_DIR/rabbitmq_client.csr" \
    -CA "$CA_DIR/ca_cert.pem" -CAkey "$CA_DIR/ca_key.pem" \
    -CAcreateserial -out "$SERVICE_DIR/rabbitmq_client_cert.pem" \
    -days 365 -sha256 \
    -extfile "$SERVICE_DIR/rabbitmq_client_ext.cnf"

    log_success "--CERTIFICADO DE CLIENTE RABBITMQ PARA $service GERADO--"

    ######################################################## JWT KEYS (account)

    if [ "$service" = "account" ]; then
        log_info "[3/5] Gerando chaves JWT para: $service"
        
        ssh-keygen -t rsa -P "" -b 2048 -m PEM -f "$SERVICE_DIR/jwt.key"
        ssh-keygen -e -m PEM -f "$SERVICE_DIR/jwt.key" > "$SERVICE_DIR/jwt.key.pub"
        
        [ -d "$CERTS_DIR/api-gtw" ] && cp "$SERVICE_DIR/jwt.key.pub" "$CERTS_DIR/api-gtw/"
        
        log_success "--CHAVES JWT PARA $service GERADAS--"
    fi
    
done

############################################## 4 - LIMPEZA DE ARQUIVOS TEMPORÁRIOS
rm -rf $CERTS_DIR/ca $CERTS_DIR/**/*.csr $CERTS_DIR/**/*.cnf $CERTS_DIR/*.cnf

log_success "--ARQUIVOS TEMPORÁRIOS REMOVIDOS--"

log_success "🎉 TODOS OS CERTIFICADOS FORAM GERADOS COM SUCESSO!"