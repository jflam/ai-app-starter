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
CMD ["sh", "-c", "node dist/migrate.js && node dist/index.js"]
