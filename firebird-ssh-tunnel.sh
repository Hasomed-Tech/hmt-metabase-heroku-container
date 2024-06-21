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
ELEPHANT_TEST_REMOTE_PORT=${ELEPHANT_TEST_REMOTE_PORT}
ELEPHANT_TEST_REMOTE_PASSWORD=${ELEPHANT_TEST_REMOTE_PASSWORD}

# Function to establish SSH tunnel using sshpass and ssh.
start_tunnel() {
    SSH_TUNNEL_PID=$(netstat -tulnp | grep ":${ELEPHANT_TEST_LOCAL_PORT} " | awk '{print $7}' | cut -d'/' -f1)
    
    if [ -n "${SSH_TUNNEL_PID}" ]; then
        echo "Closing existing SSH tunnel with PID: $SSH_TUNNEL_PID"
        kill $SSH_TUNNEL_PID
        wait $SSH_TUNNEL_PID 2>/dev/null
    fi

    sshpass -p ${ELEPHANT_TEST_REMOTE_PASSWORD} ssh -o StrictHostKeyChecking=no -L 127.0.0.1:${ELEPHANT_TEST_LOCAL_PORT}:127.0.0.1:${ELEPHANT_TEST_REMOTE_PORT} ${ELEPHANT_TEST_REMOTE_USER}@${ELEPHANT_TEST_REMOTE_HOST} -N &
    SSH_TUNNEL_PID=$!
    echo "SSH tunnel established with PID: $SSH_TUNNEL_PID"
}

# Function to check if the tunnel is still active.
check_tunnel() {
    if ! netstat -tln | grep -q ":${ELEPHANT_TEST_LOCAL_PORT} "; then
        echo "SSH tunnel is down. Reconnecting..."
        start_tunnel
    else
        echo "SSH tunnel is still active."
    fi
}

# Establish the initial SSH tunnel.
start_tunnel

# Infinite loop to keep the SSH tunnel alive, run in the background.
(while true; do
    check_tunnel
    sleep 10 # Check the tunnel status every 10 seconds
done) &