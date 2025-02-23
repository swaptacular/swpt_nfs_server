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

# Check if the GIT_REPOSITORY variable is empty
if [ -z "${GIT_REPOSITORY}" ]; then
  echo "The GIT_REPOSITORY environment variable is unset or null, exiting..."
  exit 1
fi

# Set 'unofficial Bash Strict Mode' as described here: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Initialize the shared directory if necessary
if [ -z "$( ls -A ${SHARED_DIRECTORY})" ]; then
  git clone "${GIT_REPOSITORY}" "${SHARED_DIRECTORY}"
fi
cd "${SHARED_DIRECTORY}"

# This loop periodically pulls the Git repository
while true; do
  git pull --ff-only

  # Seep for $GIT_PULL_SECONDS seconds (60 by default)
  sleep "${GIT_PULL_SECONDS-60}"
done

exit 1
