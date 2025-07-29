# Barbershop System

This is the general repository for the Barbershop application, a comprehensive system for managing barbershops, including scheduling, customer management, and more. This repository contains the necessary configurations and scripts to deploy the entire application using Docker.

## Deployment

### Prerequisites
- Docker
- Docker Compose
- OpenSSL

### 1. Certificate and Key Generation

To ensure secure communication between services, you need to generate certificates and keys.

**Development Certificates:**

Run the script to generate certificates for the services:
```bash
./generate-dev-certs.sh
```
This script will create a `.certs` directory with the necessary certificates for each service.

**Database Encryption Keys:**

Run the script to generate encryption keys for the database:
```bash
./generate-db-keys.sh
```
This script will create an `.encryption_keys` directory with the keys for the services that use a database.

### 2. Environment Configuration

Create a `.env` file in the project root with the following environment variables:

```
# MongoDB Variables
MONGO_ACCOUNT_ROOT_USER=admin
MONGO_ACCOUNT_ROOT_PASS=admin123
MONGO_SCHEDULE_MANAGEMENT_ROOT_USER=admin
MONGO_SCHEDULE_MANAGEMENT_ROOT_PASS=admin123

# RabbitMQ Variables
ACCOUNT_RABBITMQ_URI=amqp://guest:guest@rabbitmq:5672
SCHEDULE_MANAGEMENT_RABBITMQ_URI=amqp://guest:guest@rabbitmq:5672

# Admin Email and Password
ADMIN_EMAIL=admin@example.com
ADMIN_PASSWORD=admin

# Other variables
NODE_ENV=development
API_GATEWAY_HOSTNAME=localhost
WEB_APP_HOSTNAME=localhost
ACC_ENCRYPT_SECRET_KEY=your_secret_key
SALT_GENERATOR_VALUE=your_salt_value
ISIS_TOKEN=your_isis_token
SSL_KEY_PATH=./.certs/api-gtw/server_key.pem
SSL_CERT_PATH=./.certs/api-gtw/server_cert.pem
```

### 3. Running the Application

With the certificates, keys, and `.env` file configured, run the following command to start the application:

```bash
docker-compose up --build -d
```

The application will be available at the following addresses:

- **API Gateway:** `https://localhost:8081`
- **RabbitMQ Management:** `http://localhost:15672`
