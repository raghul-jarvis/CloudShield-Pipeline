# Stage 1: Build compilation environment
FROM node:20-alpine AS builder
WORKDIR /app

# Safely copy package manifests if they exist
COPY package*.json ./

# Install packages only if package.json exists, otherwise bypass gracefully
RUN if [ -f package.json ]; then npm ci --quiet; fi

# Copy all source assets into workspace
COPY . .

# Run build compilation script if it exists in package.json
RUN if grep -q '"build":' package.json 2>/dev/null; then npm run build; fi


# Stage 2: Minimalist Production Environment
FROM nginx:1.25-alpine

# Strip default generic index directories out of Nginx config
RUN rm -rf /usr/share/nginx/html/*

# CRITICAL FIX (Line 20): Explicitly handle static code vs framework bundles.
# If your project uses a build step (dist/), change the source directory to './dist'.
# If your project is pure HTML/CSS/JS (no build step), leave it as '.' to copy the root directory.
COPY --from=builder /app/. /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]