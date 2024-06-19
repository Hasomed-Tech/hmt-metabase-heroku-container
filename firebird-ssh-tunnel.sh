#!/bin/bash

# This script is necessary because the Metabase driver for Firebird does not support SSH tunneling.
# Therefore, we need this script to establish and maintain an SSH tunnel manually.
# The SSH tunnel forwards a local port to a remote port on the Firebird server,
# enabling secure communication between Metabase and the Firebird database over SSH.
# The script includes a loop to reconnect automatically if the connection is interrupted.

# Define SSH tunnel parameters.
# ELEPHANT_TEST_REMOTE_USER: The username to use for SSH login.
# ELEPHANT_TEST_REMOTE_HOST: The remote host to connect to via SSH.
# ELEPHANT_TEST_LOCAL_PORT: The local port to bind for the SSH tunnel.
# ELEPHANT_TEST_REMOTE_PORT: The remote port to forward to through the SSH tunnel.
# ELEPHANT_TEST_REMOTE_PASSWORD: The password for the SSH user.

ELEPHANT_TEST_REMOTE_USER=${ELEPHANT_TEST_REMOTE_USER}
ELEPHANT_TEST_REMOTE_HOST=${ELEPHANT_TEST_REMOTE_HOST}
ELEPHANT_TEST_LOCAL_PORT=${ELEPHANT_TEST_LOCAL_PORT}
ELEPHANT_TEST_REMOTE_PORT=#{ELEPHANT_TEST_REMOTE_PORT}
ELEPHANT_TEST_REMOTE_PASSWORD=${ELEPHANT_TEST_REMOTE_PASSWORD}

# Function to establish SSH tunnel using sshpass and ssh.
# This function will create an SSH tunnel that forwards 
# local port 3050 to the remote port 3050 on the remote host.
start_tunnel() {
    sshpass -p ${ELEPHANT_TEST_REMOTE_PASSWORD} ssh -o StrictHostKeyChecking=no -L 127.0.0.1:${ELEPHANT_TEST_LOCAL_PORT}:127.0.0.1:${ELEPHANT_TEST_REMOTE_PORT} ${ELEPHANT_TEST_REMOTE_USER}@${ELEPHANT_TEST_REMOTE_HOST} -N
}

# Infinite loop to keep the SSH tunnel alive.
# If the tunnel gets disconnected, it will wait for 5 seconds
# and then attempt to reconnect.
while true; do
    start_tunnel
    echo "SSH connection interrupted. Reconnecting in 5 seconds..."
    sleep 5
done