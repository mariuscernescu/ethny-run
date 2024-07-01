#!/bin/bash

set -e

# Source environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found"
    exit 1
fi

# Check for required tools
# command -v curl >/dev/null 2>&1 || { echo "Error: curl is required but not installed. Install with 'brew install curl'"; exit 1; }
# command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not installed. Install with 'brew install jq'"; exit 1; }
# command -v wget >/dev/null 2>&1 || { echo "Error: wget is required but not installed. Install with 'brew install wget'"; exit 1; }
# command -v python3 >/dev/null 2>&1 || { echo "Error: python3 is required but not installed. Install with 'brew install python3'"; exit 1; }
# python3 -c "import minio" >/dev/null 2>&1 || { echo "Error: minio is required but not installed. Install with 'pip3 install minio'"; exit 1; }
# python3 -c "import web3" >/dev/null 2>&1 || { echo "Error: web3 is required but not installed. Install with 'pip3 install web3==5.17.0'"; exit 1; }
# python3 -c "from eth_account import Account" >/dev/null 2>&1 || { echo "Error: eth_account is required but not installed. Install with 'pip3 install eth_account'"; exit 1; }

# Set up local registry path
export REGISTRY_PATH=../ethny-build/registry

RUNNER_TYPE="nodenithy"
echo "VERSION = ${VERSION}"

cd run

echo "ETNY MODE: ${ETNY_MODE}"

# Determine MRENCLAVE values
export MRENCLAVE_SECURELOCK=$(docker-compose run -e SCONE_LOG=INFO -e SCONE_HASH=1 etny-securelock | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | tr -d '\r')
export MRENCLAVE_TRUSTEDZONE=$(docker-compose run -e SCONE_LOG=INFO -e SCONE_HASH=1 etny-trustedzone | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | tr -d '\r')
export MRENCLAVE_VALIDATOR=$(docker-compose run -e SCONE_LOG=INFO -e SCONE_HASH=1 etny-validator | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | tr -d '\r')

echo "MRENCLAVE_SECURELOCK: ${MRENCLAVE_SECURELOCK}"
echo "MRENCLAVE_TRUSTEDZONE: ${MRENCLAVE_TRUSTEDZONE}"
echo "MRENCLAVE_VALIDATOR: ${MRENCLAVE_VALIDATOR}"

# Generate enclave names
ENCLAVE_NAME_SECURELOCK=$(echo ENCLAVE_NAME_SECURELOCK_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#g' | sed 's#-#_#g')
PREDECESSOR_NAME_SECURELOCK=$(echo PREDECESSOR_SECURELOCK_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#g' | sed 's#-#_#g')

echo
echo "ENCLAVE_NAME_SECURELOCK: ${ENCLAVE_NAME_SECURELOCK}"
echo "PREDECESSOR_NAME_SECURELOCK: ${PREDECESSOR_NAME_SECURELOCK}"
echo

export ENCLAVE_NAME_SECURELOCK
PREDECESSOR_HASH_SECURELOCK=$(eval "echo \${$PREDECESSOR_NAME_SECURELOCK}")

# Set default values only if environment variables are not set
PREDECESSOR_HASH_SECURELOCK=${PREDECESSOR_HASH_SECURELOCK:-"EMPTY"}

# Debug: Print environment variables
echo "PREDECESSOR_HASH_SECURELOCK: ${PREDECESSOR_HASH_SECURELOCK}"
echo "MRENCLAVE_SECURELOCK: ${MRENCLAVE_SECURELOCK}"
echo "ENCLAVE_NAME_SECURELOCK: ${ENCLAVE_NAME_SECURELOCK}"

# Process etny-securelock-test.yaml
if [ ! -f etny-securelock-test.yaml.tpl ]; then
    echo "Error: Template file etny-securelock-test.yaml.tpl not found!"
    exit 1
fi

if [ "${PREDECESSOR_HASH_SECURELOCK}" = "EMPTY" ]; then
    sed -e "s|__PREDECESSOR__|# predecessor: ${PREDECESSOR_HASH_SECURELOCK}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_SECURELOCK}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_SECURELOCK}|g" \
        etny-securelock-test.yaml.tpl > etny-securelock-test.yaml
else
    sed -e "s|__PREDECESSOR__|predecessor: ${PREDECESSOR_HASH_SECURELOCK}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_SECURELOCK}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_SECURELOCK}|g" \
        etny-securelock-test.yaml.tpl > etny-securelock-test.yaml
fi

echo "Contents of etny-securelock-test.yaml:"
cat etny-securelock-test.yaml

echo "Checking for remaining placeholders:"
grep -n "__.*__" etny-securelock-test.yaml || echo "No placeholders found."

echo "##############################################################################################################"

ENCLAVE_NAME_TRUSTEDZONE=$(echo ENCLAVE_NAME_TRUSTEDZONE_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#g' | sed 's#-#_#g')
PREDECESSOR_NAME_TRUSTEDZONE=$(echo PREDECESSOR_TRUSTEDZONE_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#g' | sed 's#-#_#g')

echo
echo "ENCLAVE_NAME_TRUSTEDZONE: ${ENCLAVE_NAME_TRUSTEDZONE}"
echo "PREDECESSOR_NAME_TRUSTEDZONE: ${PREDECESSOR_NAME_TRUSTEDZONE}"
echo

export ENCLAVE_NAME_TRUSTEDZONE
PREDECESSOR_HASH_TRUSTEDZONE=$(eval "echo \${$PREDECESSOR_NAME_TRUSTEDZONE}")
PREDECESSOR_HASH_TRUSTEDZONE=${PREDECESSOR_HASH_TRUSTEDZONE:-"EMPTY"}

# Debug: Print environment variables
echo "PREDECESSOR_HASH_TRUSTEDZONE: ${PREDECESSOR_HASH_TRUSTEDZONE}"
echo "MRENCLAVE_TRUSTEDZONE: ${MRENCLAVE_TRUSTEDZONE}"
echo "MRENCLAVE_VALIDATOR: ${MRENCLAVE_VALIDATOR}"
echo "ENCLAVE_NAME_TRUSTEDZONE: ${ENCLAVE_NAME_TRUSTEDZONE}"

# Process etny-trustedzone-test.yaml
if [ ! -f etny-trustedzone-test.yaml.tpl ]; then
    echo "Error: Template file etny-trustedzone-test.yaml.tpl not found!"
    exit 1
fi

if [ "${PREDECESSOR_HASH_TRUSTEDZONE}" = "EMPTY" ]; then
    sed -e "s|__PREDECESSOR__|# predecessor: ${PREDECESSOR_HASH_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE_VALIDATOR__|${MRENCLAVE_VALIDATOR}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_TRUSTEDZONE}|g" \
        etny-trustedzone-test.yaml.tpl > etny-trustedzone-test.yaml
else
    sed -e "s|__PREDECESSOR__|predecessor: ${PREDECESSOR_HASH_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE_VALIDATOR__|${MRENCLAVE_VALIDATOR}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_TRUSTEDZONE}|g" \
        etny-trustedzone-test.yaml.tpl > etny-trustedzone-test.yaml
fi

echo "Contents of etny-trustedzone-test.yaml:"
cat etny-trustedzone-test.yaml

echo "Checking for remaining placeholders:"
grep -n "__.*__" etny-trustedzone-test.yaml || echo "No placeholders found."

echo "# Update docker-compose files"

# Update docker-compose files
for file in docker-compose.yml docker-compose-final.yml; do
    if [ ! -f "$file" ]; then
        echo "Error: $file not found!"
        continue
    fi

    echo "Processing $file"
    echo "ENCLAVE_NAME_SECURELOCK: ${ENCLAVE_NAME_SECURELOCK}"
    echo "ENCLAVE_NAME_TRUSTEDZONE: ${ENCLAVE_NAME_TRUSTEDZONE}"

    echo "Checking for placeholders before replacement:"
    grep "__ENCLAVE_NAME_SECURELOCK__" "$file" || echo "No __ENCLAVE_NAME_SECURELOCK__ found in $file"
    grep "__ENCLAVE_NAME_TRUSTEDZONE__" "$file" || echo "No __ENCLAVE_NAME_TRUSTEDZONE__ found in $file"

    sed -i '' -e "s|__ENCLAVE_NAME_SECURELOCK__|${ENCLAVE_NAME_SECURELOCK}|g" \
              -e "s|__ENCLAVE_NAME_TRUSTEDZONE__|${ENCLAVE_NAME_TRUSTEDZONE}|g" \
              "$file"

    echo "Checking for placeholders after replacement:"
    grep "__ENCLAVE_NAME_SECURELOCK__" "$file" || echo "No __ENCLAVE_NAME_SECURELOCK__ found in $file"
    grep "__ENCLAVE_NAME_TRUSTEDZONE__" "$file" || echo "No __ENCLAVE_NAME_TRUSTEDZONE__ found in $file"

    echo "Contents of $file:"
    cat "$file"
    echo
done

# Get PUBLIC_KEY for SECURELOCK
export PUBLIC_KEY_SECURELOCK_RES=$(docker-compose run etny-securelock | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | sed 's/.*PUBLIC_KEY:\s*//' | tr -d '\r')
export CERTIFICATE_CONTENT_SECURELOCK=$(echo "${PUBLIC_KEY_SECURELOCK_RES}" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | sed -e '/-----BEGIN CERTIFICATE-----/d' -e '/-----END CERTIFICATE-----/d')
if [ -z "${CERTIFICATE_CONTENT_SECURELOCK}" ]; then
  echo "ERROR! PUBLIC_KEY_SECURELOCK not found"
  exit 1
else
  echo "FOUND PUBLIC_KEY_SECURELOCK"
fi
export PUBLIC_KEY_SECURELOCK="-----BEGIN CERTIFICATE-----\n${CERTIFICATE_CONTENT_SECURELOCK}\n-----END CERTIFICATE-----"
echo -e "${PUBLIC_KEY_SECURELOCK}" > certificate.securelock.crt
echo "Listing certificate PUBLIC_KEY_SECURELOCK:"
cat certificate.securelock.crt

# Get PUBLIC_KEY for TRUSTEDZONE
export PUBLIC_KEY_TRUSTEDZONE_RES=$(docker-compose run etny-trustedzone | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | sed 's/.*PUBLIC_KEY:\s*//' | tr -d '\r')
export CERTIFICATE_CONTENT_TRUSTEDZONE=$(echo "${PUBLIC_KEY_TRUSTEDZONE_RES}" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | sed -e '/-----BEGIN CERTIFICATE-----/d' -e '/-----END CERTIFICATE-----/d')
if [ -z "${CERTIFICATE_CONTENT_TRUSTEDZONE}" ]; then
  echo "ERROR! PUBLIC_KEY_TRUSTEDZONE not found"
  exit 1
else
  echo "FOUND PUBLIC_KEY_TRUSTEDZONE"
fi
export PUBLIC_KEY_TRUSTEDZONE="-----BEGIN CERTIFICATE-----\n${CERTIFICATE_CONTENT_TRUSTEDZONE}\n-----END CERTIFICATE-----"
echo -e "${PUBLIC_KEY_TRUSTEDZONE}" > certificate.trustedzone.crt
echo "Listing certificate PUBLIC_KEY_TRUSTEDZONE:"
cat certificate.trustedzone.crt

echo "**** Started ipfs ****"
if [ -f ipfs.sh ]; then
    chmod +x ipfs.sh
    ./ipfs.sh
else
    echo "Warning: ipfs.sh not found. Skipping IPFS setup."
fi
echo "**** Finished ipfs ****"

echo "Adding certificates for SECURELOCK and TRUSTEDZONE into IMAGE REGISTRY smart contract..."
if [ -f image_registry_runner.py ]; then
    python3 image_registry_runner.py
else
    echo "Warning: image_registry_runner.py not found. Skipping certificate addition to IMAGE REGISTRY smart contract."
fi

echo "Script completed successfully."