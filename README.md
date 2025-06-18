# Node.js Docker App

Node.js application with Express and PostgreSQL, containerized with Docker and deployable to AWS ECS.

## 📋 Description

This is a simple web application built with Node.js and Express that connects to a PostgreSQL database. The application displays a greeting message along with the current time obtained from the database. It's fully containerized and ready for deployment on AWS ECS with RDS PostgreSQL.

## 🚀 Features

- **Express.js**: Minimalist web framework for Node.js
- **PostgreSQL**: Relational database with SSL support
- **Docker**: Containerization with multi-stage build
- **Docker Compose**: Local service orchestration
- **AWS ECS**: Production deployment with Fargate
- **CI/CD**: Automated deployment pipeline to AWS
- **Testing**: Test suite with Jest and Supertest
- **Security**: SSL configuration and AWS secrets management

## 🛠️ Technologies

- Node.js 18
- Express.js 4.21.2
- PostgreSQL 15 (RDS in production)
- Docker & Docker Compose
- AWS CLI
- Jest (testing)

## 📦 Installation

### Local Development

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd node-app
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Configure environment variables**
   

### With Docker Compose

1. **Start services**
   ```bash
   docker-compose up -d
   ```

   This will start:
   - Node.js application on port 3000
   - PostgreSQL on port 5432

2. **Verify functionality**
   ```bash
   curl http://localhost:3000
   ```

## 🧪 Testing

Run the tests:
```bash
npm test
```

Tests include:
- Main endpoint verification
- PostgreSQL connection mocking
- HTTP response validation

## 🐳 Docker

### Manual Build

```bash
# Build image
docker build -t node-app .

# Run container
docker run -p 3000:3000 --env-file .env node-app
```

### Multi-stage Architecture

The Dockerfile uses a multi-stage build to optimize the final size:
1. **Builder stage**: Installs dependencies and compiles
2. **Production stage**: Lightweight image with AWS CLI included

## ☁️ AWS ECS Deployment

### Prerequisites

1. **Configured AWS CLI** with permissions for:
   - ECR (Elastic Container Registry)
   - ECS (Elastic Container Service)
   - RDS (for PostgreSQL database)
   - AWS Parameter Store (for secrets management)

2. **Database**: RDS PostgreSQL instance configured and accessible from ECS

3. **Secrets**: Database credentials and configuration stored in AWS Parameter Store



### CI/CD Pipeline

The application includes a continuous integration and deployment pipeline that automatically:
1. Builds the Docker image on code changes
2. Pushes the new image to ECR
3. Updates the ECS service with the latest image
4. Performs health checks to ensure successful deployment

### Manual Deployment

```bash
chmod +x deploy-ecs.sh
./deploy-ecs.sh
```
1. Fetches configuration from AWS Parameter Store
2. Authenticates with ECR
3. Builds and tags the Docker image
4. Pushes the image to ECR
5. Registers new task definition with RDS connection
6. Updates the ECS service

## 🔧 Configuration


### Database Connection

The application connects to RDS PostgreSQL in production. SSL connections are supported when configured. 

## 📁 Project Structure

```
node-app/
├── server.js              # Main application
├── package.json           # Dependencies and scripts
├── Dockerfile            # Docker configuration
├── docker-compose.yml    # Local orchestration
├── entrypoint.sh         # Startup script
├── deploy-ecs.sh         # AWS deployment script
├── tests/
│   └── server.test.js    # Unit tests
└── README.md             # Documentation
```

## 🔍 Endpoints

### `GET /`
Main endpoint that returns a greeting with the current time from PostgreSQL.

**Successful response:**
```
¡Hello, Docker! 🐳 The time ⏱️ in PostgreSQL is: 2024-01-01T12:00:00.000Z
```

**Connection error response:**
```
🔥 PostgreSQL connection error. Check your DB configuration. 🔥
```


## 📝 NPM Scripts

- `npm start`: Start the application
- `npm test`: Run tests


