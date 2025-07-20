############################################## FUNCTIONS OF GENERATION OPENSSL CONFIGS

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

generate_openssl_conf_mongodb_server() {
  local path="$1"
  cat > "$path/mongodb_server_openssl.cnf" <<EOF
[ req ]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[ req_distinguished_name ]
countryName_default = BR
stateOrProvinceName_default = Paraiba
localityName_default = CampinaGrande
organizationName_default = Barbershop Service
commonName_default = mongodb

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = mongodb
DNS.3 = mongo
EOF
}

generate_openssl_conf_mongodb_server_ext() {
  local path="$1"
  cat > "$path/mongodb_server_ext.cnf" <<EOF
basicConstraints = CA:false
keyUsage         = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName   = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = mongodb
DNS.3 = mongo
EOF
}

generate_openssl_conf_rabbitmq_server() {
  local path="$1"
  cat > "$path/rabbitmq_server_openssl.cnf" <<EOF
[ req ]
distinguished_name = req_distinguished_name
req_extensions = v3_req

[ req_distinguished_name ]
countryName_default = BR
stateOrProvinceName_default = Paraiba
localityName_default = CampinaGrande
organizationName_default = Barbershop Service
commonName_default = rabbitmq

[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = rabbitmq
DNS.3 = rabbit
EOF
}

generate_openssl_conf_rabbitmq_server_ext() {
  local path="$1"
  cat > "$path/rabbitmq_server_ext.cnf" <<EOF
basicConstraints = CA:false
keyUsage         = digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName   = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = rabbitmq
DNS.3 = rabbit
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

generate_openssl_conf_mongodb_client_ext() {
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

generate_openssl_conf_rabbitmq_client() {
  local path="$1"
  local service="$2"
  cat > "$path/rabbitmq_client_openssl.cnf" <<EOF
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
DNS.2 = rabbitmq
DNS.3 = $service
EOF
}

generate_openssl_conf_rabbitmq_client_ext() {
  local path="$1"
  local service="$2"
  cat > "$path/rabbitmq_client_ext.cnf" <<EOF
basicConstraints = CA:false
keyUsage         = digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth
subjectAltName   = @alt_names

[ alt_names ]
IP.1 = 127.0.0.1
DNS.1 = localhost
DNS.2 = rabbitmq
DNS.3 = $service
EOF
}