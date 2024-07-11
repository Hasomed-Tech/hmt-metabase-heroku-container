#!/bin/bash

# Define SSH tunnel parameters.
# ELEFANT_TEST_REMOTE_USER: The username to use for SSH login.
# ELEFANT_TEST_REMOTE_HOST: The remote host to connect to via SSH.
# ELEFANT_TEST_LOCAL_PORT: The local port to bind for the SSH tunnel.
# ELEFANT_TEST_REMOTE_PORT: The remote port to forward to through the SSH tunnel.
# ELEFANT_TEST_REMOTE_PASSWORD: The password for the SSH user.

export AUTOSSH_GATETIME=0          # Don't wait at start-up before launching ssh
export AUTOSSH_POLL=10             # How often to check the connection (seconds)
export AUTOSSH_PORT=0              # A port to use for monitoring if no one is specified

ELEFANT_TEST_REMOTE_USER=${ELEFANT_TEST_REMOTE_USER}
ELEFANT_TEST_REMOTE_HOST=${ELEFANT_TEST_REMOTE_HOST}
ELEFANT_TEST_LOCAL_PORT=${ELEFANT_TEST_LOCAL_PORT}
ELEFANT_TEST_REMOTE_PORT=${ELEFANT_TEST_REMOTE_PORT}
ELEFANT_TEST_REMOTE_PASSWORD=${ELEFANT_TEST_REMOTE_PASSWORD}

pkill -f "autossh -M 0"

# Use sshpass with autossh to handle the password
sshpass -p ${ELEFANT_TEST_REMOTE_PASSWORD} autossh -f -M 0 -o "ServerAliveInterval=30" -o "ServerAliveCountMax=3" -o "StrictHostKeyChecking=no" -L ${ELEFANT_TEST_LOCAL_PORT}:localhost:${ELEFANT_TEST_REMOTE_PORT} ${ELEFANT_TEST_REMOTE_USER}@${ELEFANT_TEST_REMOTE_HOST} -N
echo "SSH tunnel established."
