# Stage 1: builder. Installs dependencies in a separated image.
FROM node:18-alpine AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++

COPY package.json package-lock.json ./

RUN npm install --omit=dev

COPY . .
# Stage 2: Ultra lightweight image
FROM node:18-alpine

WORKDIR /app

# Installs AWS CLI inside final image
RUN apk add --no-cache aws-cli

# Copy only necessary things from last stage
COPY --from=builder /app /app

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/entrypoint.sh"]