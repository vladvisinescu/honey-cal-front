FROM node:18-alpine AS development
ENV NODE_ENV=development
# Create app directory
WORKDIR /app
# Copy app source
COPY package.json ./
COPY yarn.lock ./
RUN yarn install
COPY . ./
EXPOSE 3000
CMD ["npm", "start"]

FROM node:18-alpine AS builder
ENV NODE_ENV production
# Add a work directory
WORKDIR /app
# Cache and Install dependencies
COPY package.json .
COPY yarn.lock ./
RUN yarn install --production
# Copy app files
COPY . .
# Build the app
RUN yarn build

# Bundle static assets with nginx
FROM nginx:1.21.0-alpine as production
ENV NODE_ENV production
# Copy built assets from builder
COPY --from=builder /app/build /usr/share/nginx/html
# Add your nginx.conf
COPY /docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf
# Expose port
EXPOSE 80
# Start nginx
CMD ["nginx", "-g", "daemon off;"]
