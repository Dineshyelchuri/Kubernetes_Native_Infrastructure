# Use the official Node.js image from Docker Hub
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /app


# Copy the application code to the container
COPY . .

# Install npm dependencies
RUN npm install

# Open port 3000
EXPOSE 3000

# Run the application
ENTRYPOINT [ "node" ]
CMD [ "index.js" ]
