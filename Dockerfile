
# Node.js Slim Base image
FROM node:20.12.1-slim AS builder
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies (including dev)
COPY package*.json ./
RUN npm update -g npm 
RUN npm install --unsafe-perm

# Copy source code
COPY . .

# Build the app (adjust if your build command is different)
ENV NODE_OPTIONS="--max-old-space-size=4096"
RUN npm run build

# ----------- Production Stage -----------
FROM node:20.12.1-slim AS production
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install only production dependencies
COPY package*.json ./
RUN npm update -g npm 
RUN npm install --only=production --unsafe-perm 

# Copy built output and necessary files from builder
COPY --from=builder /app/dist ./dist

# Set environment variable for production
ENV NODE_ENV=production

# Expose port
EXPOSE 3030

ENTRYPOINT ["tail", "/dev/null"]