#!/usr/bin/env bash

# Fix Docker socket permissions if it exists
if [ -e "/var/run/docker.sock" ]; then
    sudo chmod 666 /var/run/docker.sock
fi

# Write or export environment variables to the user's .bashrc
echo 'export PIPENV_IGNORE_VIRTUALENVS=1' >> "$HOME/.bashrc"

# Activate the Python virtual environment
. "$HOME/.venv/bin/activate"

# Now execute the command passed into this entrypoint
exec "$@"
