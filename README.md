# Keepstory backend

Here you can find the source code of the backend part of the Keepstory application.

## Getting Started

To run the application, please follow the instructions below.

### Prerequisites

- [Docker](https://www.docker.com/) must be installed on your system.

### Setup

1. **Generate Master Key**  
   Ensure you generate the master key required for decrypting credentials before starting up the application.

2. **Configure Credentials**  
   You need to fill in the `config/credentials.yml.enc` file with the following configuration details:

   ```yaml
   secret_key_base:

   postgres:
     user:
     password:
     db:
     production_database_password: 

   frontend_url:
   cookies_secret_key:
   kamal_registry_password: 

   aws_access_key_id:
   aws_secret_access_key:

   cloudflare_r2_access_key_id:
   cloudflare_r2_secret_access_key:
   cloudflare_r2_endpoint:

Make sure that each field is properly set to reflect your environment configuration.

3. **Build and Start the Containers**
   Use Docker Compose to build and run the application:
    ```bash
    docker compose build
    docker compose up

This will build the required Docker images and start all necessary containers.