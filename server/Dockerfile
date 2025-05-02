FROM node:18-alpine AS base

# Create app directory
WORKDIR /app

# Install dependencies
FROM base AS deps
COPY package.json package-lock.json* ./
RUN npm ci

# Copy the rest of the files
FROM deps AS runner
COPY . .

# Ensure the TypeScript files are compiled
RUN npm run build

EXPOSE 4000
ENV PORT=4000
ENV NODE_ENV=production

# Run migrations and start the server directly
# Added error handling and retries for migrations
CMD ["sh", "-c", "for i in {1..5}; do echo \"Attempt $i: Running migrations and seeds...\" && node dist/migrate.js && break || sleep 5; done && node dist/index.js"]
