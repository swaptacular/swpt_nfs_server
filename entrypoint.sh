#!/bin/sh

case "$1" in
  git-pull)
    source /usr/bin/git-pull.sh
    ;;
  nfsd | '')
    source /usr/bin/nfsd.sh
    ;;
  *)
    exec "$@"
    ;;
esac
