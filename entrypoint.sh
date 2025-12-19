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

# Check for Azure Managed Identity environment
if [[ -n "${IDENTITY_ENDPOINT}" && -n "${IDENTITY_HEADER}" ]]; then
  echo "=== Azure MI Debug Info ==="
  echo "IDENTITY_ENDPOINT exists: yes"
  echo "IDENTITY_HEADER exists: yes"
  echo "DB_PASSWORD provided: $(if [[ -n "${DB_PASSWORD}" ]]; then echo "yes"; else echo "no"; fi)"
  
  # Only try to get token if DB_PASSWORD is not provided
  if [[ -z "${DB_PASSWORD}" ]]; then
    echo "Azure Managed Identity detected, obtaining access token for MySQL..."
    
    # Set the resource for Azure Database for MySQL
    RESOURCE="https://ossrdbms-aad.database.windows.net"
    API_VERSION="2019-08-01"
    
    TOKEN_URL="${IDENTITY_ENDPOINT}?resource=${RESOURCE}&api-version=${API_VERSION}"
    if [[ -n "${AZURE_CLIENT_ID}" ]]; then
      TOKEN_URL="${TOKEN_URL}&client_id=${AZURE_CLIENT_ID}"
      echo "Using AZURE_CLIENT_ID for User Assigned Managed Identity"
    else
      echo "No AZURE_CLIENT_ID provided, assuming System Assigned Managed Identity"
    fi

    echo "Requesting token from: ${TOKEN_URL}"
    # Request token from the Managed Identity endpoint (with more verbose output)
    TOKEN_RESPONSE=$(curl -v -s -H "X-IDENTITY-HEADER: $IDENTITY_HEADER" \
      "${TOKEN_URL}" 2>&1)
    
    # Save curl exit status
    CURL_STATUS=$?
    echo "Curl exit status: $CURL_STATUS"
    echo "Token response length: ${#TOKEN_RESPONSE} characters"
    
    # Check if curl was able to connect
    if [[ $CURL_STATUS -ne 0 ]]; then
      echo "Failed to connect to Managed Identity endpoint"
      echo "Curl response: ${TOKEN_RESPONSE}"
      echo "Will use provided DB_PASSWORD if available"
    else
      # Extract the access token
      ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
      
      if [[ -n "${ACCESS_TOKEN}" ]]; then
        echo "Successfully obtained access token (${#ACCESS_TOKEN} characters)"
        export DB_PASSWORD="${ACCESS_TOKEN}"
        
        # Enable cleartext plugin for MySQL authentication with token
        export LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1
        echo "Set LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1"
      else
        echo "Failed to extract access token from response"
        echo "Response excerpt: ${TOKEN_RESPONSE:0:100}..." 
        echo "Will use provided DB_PASSWORD if available"
      fi
    fi
  else
    echo "DB_PASSWORD is already set, skipping Azure MI token acquisition"
    echo "Setting LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1 for compatibility"
    export LIBMYSQL_ENABLE_CLEARTEXT_PLUGIN=1
  fi
  echo "=== End of Azure MI Debug Info ==="
fi

if [[ -n "${DB_HOST}" && -n "${DB_PORT}" ]]; then
  waitForConnection $DB_HOST $DB_PORT
fi

exec "$@"
