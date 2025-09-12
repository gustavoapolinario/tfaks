#!/bin/bash

# Exits on any error (-e)
# Exits on undefined variables (-u)
# Exits on pipeline failures (-o pipefail)
set -euo pipefail

CERT_NAME="local-tls-cert"
NAMESPACE="dev"
DAYS=365

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
mkdir -p "$SCRIPT_DIR/../tls"
cd "$SCRIPT_DIR/../tls"

generate_local_certificate_if_dont_exists() {
  if [[ -f "$CERT_NAME.key" && -f "$CERT_NAME.crt" ]]; then
    echo "Certificate files already exist. Skipping generation."
    return
  fi

  # Generate private key
  echo "Generating private key..."
  openssl genrsa -out "$CERT_NAME.key" 2048

  # Generate certificate signing request (CSR)
  echo "Generating certificate signing request..."
  openssl req -new -key "$CERT_NAME.key" -out csr.pem -subj "/CN=localhost/O=Local Development"

  # Generate self-signed certificate
  echo "Generating self-signed certificate..."
  openssl x509 -req -in csr.pem -signkey "$CERT_NAME.key" -out "$CERT_NAME.crt" -days "$DAYS"

  # Clean up CSR file
  rm -f csr.pem

  echo "Certificate generated successfully!"
  echo "Key file: $CERT_NAME.key"
  echo "Cert file: $CERT_NAME.crt"

  # Verify the certificate
  echo "Verifying certificate..."
  openssl x509 -in "$CERT_NAME.crt" -text -noout | head -10
}

import_local_certificate_to_kubernetes() {
  # Create Kubernetes TLS secret
  echo "Creating Kubernetes TLS secret..."
  kubectl create secret tls "$CERT_NAME" \
      --namespace="$NAMESPACE" \
      --key="$CERT_NAME.key" \
      --cert="$CERT_NAME.crt"

  echo "TLS secret '$CERT_NAME' created successfully in namespace '$NAMESPACE'!"
}


generate_local_certificate_if_dont_exists
import_local_certificate_to_kubernetes
