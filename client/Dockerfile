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
FROM nginx:alpine AS runner

# Copy the build output
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy custom nginx config
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
