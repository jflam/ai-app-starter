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

# Create a startup script to run migrations and start the server
RUN echo "#!/bin/sh\nnode dist/migrate.js && npm start" > /app/startup.sh && \
    chmod +x /app/startup.sh

CMD ["/app/startup.sh"]
