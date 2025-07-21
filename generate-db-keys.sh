#!/usr/bin/env bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() { echo -e "${YELLOW}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Diretório onde as chaves serão armazenadas
KEYS_DIR="$(pwd)/.encryption_keys"
SERVICES_NAMES=("account" "schedule-management") # Coloque os serviços que precisam de chaves
KEY_SIZE=256  # Tamanho da chave em bits (128, 192 ou 256)

mkdir -p "$KEYS_DIR"

log_info "Gerando chaves de criptografia em repouso para os serviços..."

for service in "${SERVICES_NAMES[@]}"; do
    SERVICE_DIR="$KEYS_DIR/$service"
    mkdir -p "$SERVICE_DIR"

    # Nome da chave
    KEY_FILE="$SERVICE_DIR/encryption.key"

    log_info "Gerando chave AES-$KEY_SIZE para: $service"
    # Gera chave binária e codifica em base64
    openssl rand -out "$KEY_FILE" $(($KEY_SIZE / 8))
    chmod 600 "$KEY_FILE"

    log_success "Chave de criptografia gerada: $KEY_FILE"
done

log_success "🎉 Todas as chaves de criptografia em repouso foram geradas com sucesso!"