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

Copy the `.env.example` file in the project root like `.env` with the environment variables running:

```bash
cp .env.example .env
```

### 3. Running the Application

With the certificates, keys, and `.env` file configured, run the following command to start the application:

```bash
docker-compose up --build -d
```

The application will be available at the following addresses:

- **API Gateway:** `https://localhost:8081`
- **RabbitMQ Management:** `http://localhost:15672`
