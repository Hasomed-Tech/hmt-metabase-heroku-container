# Stage 1: Base image with Alpine to install sshpass
FROM alpine:latest as builder

# Install dependencies for building
RUN apk add --no-cache openssh-client sshpass

# Stage 2: Metabase image
# Using Metabase version 0.47.13 because it is the highest version that currently works with the Firebird plugin
FROM metabase/metabase:v0.47.13

# Copy SSH tools from builder image
COPY --from=builder /usr/bin/ssh /usr/bin/ssh
COPY --from=builder /usr/bin/sshpass /usr/bin/sshpass

COPY docker-entrypoint.sh /app/

# Download the custom Firebird driver for Metabase
RUN wget -O /app/firebird.metabase-driver.jar https://github.com/evosec/metabase-firebird-driver/releases/download/v1.5.0/firebird.metabase-driver.jar

# Create Metabase plugins directory if it does not exist
RUN mkdir -p /plugins

# Move the Firebird driver to the plugins directory
RUN mv /app/firebird.metabase-driver.jar /plugins/

RUN ["chmod", "+x", "/app/docker-entrypoint.sh"]

# Add the SSH tunnel script
COPY firebird-ssh-tunnel.sh /app/
RUN ["chmod", "+x", "/app/firebird-ssh-tunnel.sh"]

# Run the SSH tunnel and Metabase
ENTRYPOINT ["/bin/bash", "-c", "/app/docker-entrypoint.sh"]
