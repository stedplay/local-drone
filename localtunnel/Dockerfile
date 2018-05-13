FROM node:9.11.1-alpine

# Update npm to avoid warning of npm about vulnerability.
RUN npm install -g npm@6.0.1

# Install localtunnel to access from outside network to localhost.
RUN npm install -g localtunnel@1.9.0
ENTRYPOINT ["/usr/local/bin/lt", "--port"]
