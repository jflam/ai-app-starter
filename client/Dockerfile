FROM node:18-alpine AS base

# Create app directory
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci

# Build the app
FROM deps AS builder
COPY . .
RUN npm run build

# Production image, copy all the files and run
FROM nginx:1.25-alpine AS runner

# Copy the build output
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Make sure nginx can find our files
RUN ln -sf /usr/share/nginx/html /etc/nginx/html

# Add script to handle environment variables
COPY --from=builder /app/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 80

# Use our custom entrypoint to inject environment variables into the nginx config
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
