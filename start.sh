#!/bin/sh

HOME=/root
echo 'export PIPENV_IGNORE_VIRTUALENVS=1' >> $HOME/.bashrc

# Activate the virtual environment
. $HOME/.venv/bin/activate

# Execute the command provided in the docker run
exec "$@"
