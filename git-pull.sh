#!/bin/bash

# Make sure we react to these signals by running stop() when we see them - for clean shutdown
# And then exiting
trap "stop; exit 0;" SIGTERM SIGINT

stop()
{
  # We're here because we've seen SIGTERM, likely via a Docker stop command or similar
  # Let's shutdown cleanly
  echo "SIGTERM caught, terminating Git pulling..."
  echo "Terminated."
  exit
}

# Check if the SHARED_DIRECTORY variable is empty
if [ -z "${SHARED_DIRECTORY}" ]; then
  echo "The SHARED_DIRECTORY environment variable is unset or null, exiting..."
  exit 1
fi

# Check if the NODE_DATA_SUBDIR variable is empty
if [ -z "${NODE_DATA_SUBDIR}" ]; then
  echo "The NODE_DATA_SUBDIR environment variable is unset or null, exiting..."
  exit 1
fi

# Check if the GIT_SERVER variable is empty
if [ -z "${GIT_SERVER}" ]; then
  echo "The GIT_SERVER environment variable is unset or null, exiting..."
  exit 1
fi

# Check if the GIT_PORT variable is empty
if [ -z "${GIT_PORT}" ]; then
  echo "The GIT_PORT environment variable is unset or null, exiting..."
  exit 1
fi

# Check if the GIT_REPOSITORY_PATH variable is empty
if [ -z "${GIT_REPOSITORY_PATH}" ]; then
  echo "The GIT_REPOSITORY_PATH environment variable is unset or null, exiting..."
  exit 1
fi

# Set 'unofficial Bash Strict Mode' as described here: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Initialize the shared directory if necessary
if [ -z "$( ls -A ${SHARED_DIRECTORY})" ]; then
  GIT_REPOSITORY="ssh://git@${GIT_SERVER}:${GIT_PORT}${GIT_REPOSITORY_PATH}"
  ssh-keyscan -p "${GIT_PORT}" -t rsa "${GIT_SERVER}" > /etc/ssh/ssh_known_hosts
  git clone "${GIT_REPOSITORY}" "${SHARED_DIRECTORY}"
  cp -n /etc/ssh/ssh_known_hosts "${SHARED_DIRECTORY}/.ssh_known_hosts"
fi
cd "${SHARED_DIRECTORY}"

# Ensure ".ssh_known_hosts" and "/etc/ssh/ssh_known_hosts" files exist
if ! [ -e .ssh_known_hosts ]; then
  ssh-keyscan -p "${GIT_PORT}" -t rsa "${GIT_SERVER}" > .ssh_known_hosts
fi
cp -n .ssh_known_hosts /etc/ssh/ssh_known_hosts

# Ensure a symlink to "${NODE_DATA_SUBDIR}" exists
if ! [ -e .node-data ]; then
  ln -ns "${NODE_DATA_SUBDIR}" .node-data
fi

# This loop periodically pulls the Git repository
while true; do
  git pull --ff-only

  # Seep for $GIT_PULL_SECONDS seconds (60 by default)
  sleep "${GIT_PULL_SECONDS-60}"
done

exit 1
