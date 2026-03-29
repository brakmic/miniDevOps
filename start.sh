#!/usr/bin/env bash
set -euo pipefail

# Fix Docker socket permissions if it exists
if [ -e "/var/run/docker.sock" ]; then
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
fi

# Activate the Python virtual environment
. "$HOME/.venv/bin/activate"

# Now execute the command passed into this entrypoint
exec "$@"
