#!/bin/bash

# Source environment variables
source .env

# Install required packages (use Homebrew on macOS)
# brew install curl jq wget
# pip3 install minio web3==5.17.0 eth_account

# Set up local registry path
export REGISTRY_PATH=../ethny-build/registry

RUNNER_TYPE="nodenithy"
echo "VERSION = ${VERSION}"

cd run

echo "ETNY MODE: ${ETNY_MODE}"10

# Determine MRENCLAVE values (this may need to be adjusted based on your local setup)
export MRENCLAVE_SECURELOCK=$(docker-compose run -e SCONE_LOG=INFO -e SCONE_HASH=1 etny-securelock | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | tr -d '\r')
export MRENCLAVE_TRUSTEDZONE=$(docker-compose run -e SCONE_LOG=INFO -e SCONE_HASH=1 etny-trustedzone | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | tr -d '\r')
export MRENCLAVE_VALIDATOR=$(docker-compose run -e SCONE_LOG=INFO -e SCONE_HASH=1 etny-validator | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | tr -d '\r')

echo "MRENCLAVE_SECURELOCK: ${MRENCLAVE_SECURELOCK}"
echo "MRENCLAVE_TRUSTEDZONE: ${MRENCLAVE_TRUSTEDZONE}"
echo "MRENCLAVE_VALIDATOR: ${MRENCLAVE_VALIDATOR}"

# Generate enclave names (modify as needed for your local setup)
# ENCLAVE_NAME_SECURELOCK="ENCLAVE_NAME_SECURELOCK_${VERSION}_LOCAL"
# ENCLAVE_NAME_TRUSTEDZONE="ENCLAVE_NAME_TRUSTEDZONE_${VERSION}_LOCAL"

 ENCLAVE_NAME_SECURELOCK=$(echo ENCLAVE_NAME_SECURELOCK_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#' | sed 's#-#_#')
 PREDECESSOR_NAME_SECURELOCK=$(echo PREDECESSOR_SECURELOCK_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#' | sed 's#-#_#')

echo
echo "ENCLAVE_NAME_SECURELOCK: ${ENCLAVE_NAME_SECURELOCK}"
echo "PREDECESSOR_NAME_SECURELOCK: ${PREDECESSOR_NAME_SECURELOCK}"
echo

export ENCLAVE_NAME_SECURELOCK=$(eval "echo \${$ENCLAVE_NAME_SECURELOCK}")
PREDECESSOR_HASH_SECURELOCK=$(eval "echo \${$PREDECESSOR_NAME_SECURELOCK}")

###

# Store original environment variable values
ORIGINAL_PREDECESSOR_HASH_SECURELOCK="$PREDECESSOR_HASH_SECURELOCK"
ORIGINAL_MRENCLAVE_SECURELOCK="$MRENCLAVE_SECURELOCK"
ORIGINAL_ENCLAVE_NAME_SECURELOCK="$ENCLAVE_NAME_SECURELOCK"

# Set default values only if environment variables are not set
PREDECESSOR_HASH_SECURELOCK=${PREDECESSOR_HASH_SECURELOCK:-"EMPTY"}
MRENCLAVE_SECURELOCK=${MRENCLAVE_SECURELOCK:-"DEFAULT_MRENCLAVE"}
ENCLAVE_NAME_SECURELOCK=${ENCLAVE_NAME_SECURELOCK:-"DEFAULT_ENCLAVE_NAME"}

# Debug: Print original and current environment variables
echo "Original PREDECESSOR_HASH_SECURELOCK: ${ORIGINAL_PREDECESSOR_HASH_SECURELOCK}"
echo "Current PREDECESSOR_HASH_SECURELOCK: ${PREDECESSOR_HASH_SECURELOCK}"
echo "Original MRENCLAVE_SECURELOCK: ${ORIGINAL_MRENCLAVE_SECURELOCK}"
echo "Current MRENCLAVE_SECURELOCK: ${MRENCLAVE_SECURELOCK}"
echo "Original ENCLAVE_NAME_SECURELOCK: ${ORIGINAL_ENCLAVE_NAME_SECURELOCK}"
echo "Current ENCLAVE_NAME_SECURELOCK: ${ENCLAVE_NAME_SECURELOCK}"

# Check if template file exists
if [ ! -f etny-securelock-test.yaml.tpl ]; then
    echo "Error: Template file etny-securelock-test.yaml.tpl not found!"
    exit 1
fi

# Create a temporary file for sed output
TEMP_FILE=$(mktemp)

if [ "${PREDECESSOR_HASH_SECURELOCK}" = "EMPTY" ]; then
    echo "No predecessor found. This is the first enclave for securelock."
    sed -e "s|__PREDECESSOR__|# predecessor: ${PREDECESSOR_HASH_SECURELOCK}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_SECURELOCK}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_SECURELOCK}|g" \
        etny-securelock-test.yaml.tpl > "$TEMP_FILE"
else
    sed -e "s|__PREDECESSOR__|predecessor: ${PREDECESSOR_HASH_SECURELOCK}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_SECURELOCK}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_SECURELOCK}|g" \
        etny-securelock-test.yaml.tpl > "$TEMP_FILE"
fi

# Check if sed command was successful
if [ $? -ne 0 ]; then
    echo "Error: sed command failed!"
    rm "$TEMP_FILE"
    exit 1
fi

# Move the temporary file to the final destination
mv "$TEMP_FILE" etny-securelock-test.yaml

# Debug: Print the contents of the output file
echo "Contents of etny-securelock-test.yaml:"
cat etny-securelock-test.yaml

# Debug: Check for any remaining placeholders
echo "Checking for remaining placeholders:"
grep -n "__.*__" etny-securelock-test.yaml || echo "No placeholders found."

###


# if [ "${PREDECESSOR_HASH_SECURELOCK}" = "EMPTY" ]; then
#     echo "No predecessor found. This is the first enclave for securelock."
#     cat etny-securelock-test.yaml.tpl | sed s/__PREDECESSOR__/"# predecessor: ${PREDECESSOR_HASH_SECURELOCK}"/ | sed s/__MRENCLAVE__/"${MRENCLAVE_SECURELOCK}"/ | sed s/__ENCLAVE_NAME__/"${ENCLAVE_NAME_SECURELOCK}"/ > etny-securelock-test.yaml
# else
#     cat etny-securelock-test.yaml.tpl | sed s/__PREDECESSOR__/"predecessor: ${PREDECESSOR_HASH_SECURELOCK}"/ | sed s/__MRENCLAVE__/"${MRENCLAVE_SECURELOCK}"/ | sed s/__ENCLAVE_NAME__/"${ENCLAVE_NAME_SECURELOCK}"/ > etny-securelock-test.yaml
# fi

# echo "etny-securelock-test.yaml:"
# cat etny-securelock-test.yaml
echo "##############################################################################################################"

ENCLAVE_NAME_TRUSTEDZONE=$(echo ENCLAVE_NAME_TRUSTEDZONE_${VERSION}_LOCAL | awk '{print toupper($0)}' | sed 's#/#_#' | sed 's#-#_#')
PREDECESSOR_NAME_TRUSTEDZONE=$(echo PREDECESSOR_TRUSTEDZONE_${VERSION}_LOCAL| awk '{print toupper($0)}' | sed 's#/#_#' | sed 's#-#_#')

echo
  echo "ENCLAVE_NAME_TRUSTEDZONE: ${ENCLAVE_NAME_TRUSTEDZONE}"
  echo "PREDECESSOR_NAME_TRUSTEDZONE: ${PREDECESSOR_NAME_TRUSTEDZONE}"
echo



# if [ "${PREDECESSOR_HASH_TRUSTEDZONE}" = "EMPTY" ]; then
#   echo "No predecessor found. This is the first enclave for trustedzone."
#   cat etny-trustedzone-test.yaml.tpl | sed  '' s/__PREDECESSOR__/"# predecessor: ${PREDECESSOR_HASH_TRUSTEDZONE}"/ | sed '' s/__MRENCLAVE__/"${MRENCLAVE_TRUSTEDZONE}"/ | sed '' s/__MRENCLAVE_VALIDATOR__/"${MRENCLAVE_VALIDATOR}"/ | sed '' s/__ENCLAVE_NAME__/"${ENCLAVE_NAME_TRUSTEDZONE}"/ > etny-trustedzone-test.yaml
# else
#     cat etny-trustedzone-test.yaml.tpl | sed  '' s/__PREDECESSOR__/"predecessor: ${PREDECESSOR_HASH_TRUSTEDZONE}"/ | sed '' s/__MRENCLAVE__/"${MRENCLAVE_TRUSTEDZONE}"/ | sed '' s/__MRENCLAVE_VALIDATOR__/"${MRENCLAVE_VALIDATOR}"/ | sed ''s/__ENCLAVE_NAME__/"${ENCLAVE_NAME_TRUSTEDZONE}"/ > etny-trustedzone-test.yaml
# fi

# echo
# cat etny-trustedzone-test.yaml
# echo


##

# Debug: Print original and current environment variables
echo "Original PREDECESSOR_HASH_TRUSTEDZONE: ${ORIGINAL_PREDECESSOR_HASH_TRUSTEDZONE}"
echo "Current PREDECESSOR_HASH_TRUSTEDZONE: ${PREDECESSOR_HASH_TRUSTEDZONE}"
echo "Original MRENCLAVE_TRUSTEDZONE: ${ORIGINAL_MRENCLAVE_TRUSTEDZONE}"
echo "Current MRENCLAVE_TRUSTEDZONE: ${MRENCLAVE_TRUSTEDZONE}"
echo "Original MRENCLAVE_VALIDATOR: ${ORIGINAL_MRENCLAVE_VALIDATOR}"
echo "Current MRENCLAVE_VALIDATOR: ${MRENCLAVE_VALIDATOR}"
echo "Original ENCLAVE_NAME_TRUSTEDZONE: ${ORIGINAL_ENCLAVE_NAME_TRUSTEDZONE}"
echo "Current ENCLAVE_NAME_TRUSTEDZONE: ${ENCLAVE_NAME_TRUSTEDZONE}"

# Check if template file exists
if [ ! -f etny-trustedzone-test.yaml.tpl ]; then
    echo "Error: Template file etny-trustedzone-test.yaml.tpl not found!"
    exit 1
fi

# Create a temporary file for sed output
TEMP_FILE=$(mktemp)

if [ "${PREDECESSOR_HASH_TRUSTEDZONE}" = "EMPTY" ]; then
    echo "No predecessor found. This is the first enclave for trustedzone."
    sed -e "s|__PREDECESSOR__|# predecessor: ${PREDECESSOR_HASH_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE_VALIDATOR__|${MRENCLAVE_VALIDATOR}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_TRUSTEDZONE}|g" \
        etny-trustedzone-test.yaml.tpl > "$TEMP_FILE"
else
    sed -e "s|__PREDECESSOR__|predecessor: ${PREDECESSOR_HASH_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE__|${MRENCLAVE_TRUSTEDZONE}|g" \
        -e "s|__MRENCLAVE_VALIDATOR__|${MRENCLAVE_VALIDATOR}|g" \
        -e "s|__ENCLAVE_NAME__|${ENCLAVE_NAME_TRUSTEDZONE}|g" \
        etny-trustedzone-test.yaml.tpl > "$TEMP_FILE"
fi

# Check if sed command was successful
if [ $? -ne 0 ]; then
    echo "Error: sed command failed!"
    rm "$TEMP_FILE"
    exit 1
fi

# Move the temporary file to the final destination
mv "$TEMP_FILE" etny-trustedzone-test.yaml

# Debug: Print the contents of the output file
echo "Contents of etny-trustedzone-test.yaml:"
cat etny-trustedzone-test.yaml

# Debug: Check for any remaining placeholders
echo "Checking for remaining placeholders:"
grep -n "__.*__" etny-trustedzone-test.yaml || echo "No placeholders found."



# # Update docker-compose files
# sed -i "s/__ENCLAVE_NAME_SECURELOCK__/${ENCLAVE_NAME_SECURELOCK}/" docker-compose.yml
# sed -i "s/__ENCLAVE_NAME_TRUSTEDZONE__/${ENCLAVE_NAME_TRUSTEDZONE}/" docker-compose.yml

# sed -i "s/__ENCLAVE_NAME_SECURELOCK__/${ENCLAVE_NAME_SECURELOCK}/" docker-compose-final.yml
# sed -i  "s/__ENCLAVE_NAME_TRUSTEDZONE__/${ENCLAVE_NAME_TRUSTEDZONE}/" docker-compose-final.yml

# echo
# cat docker-compose-final.yml
# echo

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

    TEMP_FILE=$(mktemp)
    sed -e "s|__ENCLAVE_NAME_SECURELOCK__|${ENCLAVE_NAME_SECURELOCK}|g" \
        -e "s|__ENCLAVE_NAME_TRUSTEDZONE__|${ENCLAVE_NAME_TRUSTEDZONE}|g" \
        "$file" > "$TEMP_FILE"

    # Check if sed command was successful
    if [ $? -ne 0 ]; then
        echo "Error: sed command failed for $file!"
        rm "$TEMP_FILE"
        continue
    fi

    # Check if any replacements were made
    if cmp -s "$file" "$TEMP_FILE"; then
        echo "No changes were made to $file"
    else
        echo "Changes were made to $file"
        # Move the temporary file to the final destination
        mv "$TEMP_FILE" "$file"
    fi

    echo "Checking for placeholders after replacement:"
    grep "__ENCLAVE_NAME_SECURELOCK__" "$file" || echo "No __ENCLAVE_NAME_SECURELOCK__ found in $file"
    grep "__ENCLAVE_NAME_TRUSTEDZONE__" "$file" || echo "No __ENCLAVE_NAME_TRUSTEDZONE__ found in $file"

    echo "Contents of $file:"
    cat "$file"
    echo
done


# # Get PUBLIC_KEY for SECURELOCK
# export PUBLIC_KEY_SECURELOCK_RES=$(docker-compose run etny-securelock | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | sed 's/.*PUBLIC_KEY:\s*//' | tr -d '\r')
# export CERTIFICATE_CONTENT_SECURELOCK=$(echo "${PUBLIC_KEY_SECURELOCK_RES}" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | sed -e '/-----BEGIN CERTIFICATE-----/d' -e '/-----END CERTIFICATE-----/d')
# if [ -z "${CERTIFICATE_CONTENT_SECURELOCK}" ]; then
#   echo "ERROR! PUBLIC_KEY_SECURELOCK not found"
#   exit 1
# else
#   echo "FOUND PUBLIC_KEY_SECURELOCK"
# fi
# export PUBLIC_KEY_SECURELOCK="-----BEGIN CERTIFICATE-----\n${CERTIFICATE_CONTENT_SECURELOCK}\n-----END CERTIFICATE-----"
# echo -e "${PUBLIC_KEY_SECURELOCK}" > certificate.securelock.crt
# echo "Listing certificate PUBLIC_KEY_SECURELOCK:"
# cat certificate.securelock.crt

# # Get PUBLIC_KEY for TRUSTEDZONE
# export PUBLIC_KEY_TRUSTEDZONE_RES=$(docker-compose run etny-trustedzone | grep -v Creating | grep -v Pulling | grep -v latest | grep -v Digest | sed 's/.*PUBLIC_KEY:\s*//' | tr -d '\r')
# export CERTIFICATE_CONTENT_TRUSTEDZONE=$(echo "${PUBLIC_KEY_TRUSTEDZONE_RES}" | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | sed -e '/-----BEGIN CERTIFICATE-----/d' -e '/-----END CERTIFICATE-----/d')
# if [ -z "${CERTIFICATE_CONTENT_TRUSTEDZONE}" ]; then
#   echo "ERROR! PUBLIC_KEY_TRUSTEDZONE not found"
#   exit 1
# else
#   echo "FOUND PUBLIC_KEY_TRUSTEDZONE"
# fi
# export PUBLIC_KEY_TRUSTEDZONE="-----BEGIN CERTIFICATE-----\n${CERTIFICATE_CONTENT_TRUSTEDZONE}\n-----END CERTIFICATE-----"
# echo -e "${PUBLIC_KEY_TRUSTEDZONE}" > certificate.trustedzone.crt
# echo "Listing certificate PUBLIC_KEY_TRUSTEDZONE:"
# cat certificate.trustedzone.crt

# echo "**** Started ipfs ****"
# chmod +x ipfs.sh
# ./ipfs.sh
# echo "**** Finished ipfs ****"

# echo "Adding certificates for SECURELOCK and TRUSTEDZONE into IMAGE REGISTRY smart contract..."
# python3 image_registry_runner.py

# echo "Waiting 10 mins before closing..."
# sleep 600