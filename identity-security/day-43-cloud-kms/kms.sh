#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
LOCATION="global"
KEYRING_NAME="my-keyring"
CRYPTOKEY_NAME="my-symmetric-key"
PLAINTEXT_FILE="plaintext.txt"
ENCRYPTED_FILE="encrypted.txt"
DECRYPTED_FILE="decrypted.txt"

# Create a KeyRing
echo "Creating KeyRing..."
gcloud kms keyrings create $KEYRING_NAME --location $LOCATION

# Create a CryptoKey
echo "Creating CryptoKey..."
gcloud kms keys create $CRYPTOKEY_NAME --location $LOCATION --keyring $KEYRING_NAME --purpose encryption

# Generate a sample plaintext file
echo "Generating plaintext file..."
echo "This is a secret message." > $PLAINTEXT_FILE

# Encrypt the plaintext file
echo "Encrypting plaintext file..."
gcloud kms encrypt --location $LOCATION --keyring $KEYRING_NAME --key $CRYPTOKEY_NAME --plaintext-file $PLAINTEXT_FILE --ciphertext-file $ENCRYPTED_FILE

# Decrypt the encrypted file
echo "Decrypting encrypted file..."
gcloud kms decrypt --location $LOCATION --keyring $KEYRING_NAME --key $CRYPTOKEY_NAME --ciphertext-file $ENCRYPTED_FILE --plaintext-file $DECRYPTED_FILE

# Display the results
echo "Plaintext:"
cat $PLAINTEXT_FILE
echo -e "\nEncrypted:"
cat $ENCRYPTED_FILE
echo -e "\nDecrypted:"
cat $DECRYPTED_FILE

# Clean up (optional)
echo "Cleaning up..."
rm -f $PLAINTEXT_FILE $ENCRYPTED_FILE $DECRYPTED_FILE
