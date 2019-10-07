#!/bin/bash

# Waits until remote DB is ready
function waitForConnection()
{
    local c=0
    until nc -z -v -w30 $1 $2
    do
      echo "Waiting for connection..."
      c=$((c + 1))
      if [ "$c" -gt 36 ]; then
          echo "wait limit timeout skipping..."
          return 1
      fi
      sleep 5
    done
}

if [[ -n "${DB_HOST}" && -n "${DB_PORT}" ]]; then
  waitForConnection $DB_HOST $DB_PORT
fi

exec "$@"