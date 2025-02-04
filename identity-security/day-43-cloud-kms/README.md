# Google Cloud KMS Encryption Demo

This Bash script demonstrates how to use **Google Cloud Key Management Service (KMS)** to encrypt and decrypt a file using a symmetric encryption key. It creates a KeyRing, generates a CryptoKey, encrypts a sample plaintext file, decrypts it, and displays the results.

## Prerequisites
1. **Google Cloud SDK**: Ensure the SDK is installed and configured.
2. **Authentication**: Log in to your Google Cloud account using `gcloud auth login`.
3. **KMS API**: Enable the **Cloud Key Management Service (KMS) API** in your Google Cloud project.

## Script Overview
The script performs the following steps:
1. **Set Variables**:
   - `PROJECT_ID`: Fetches the current Google Cloud project ID.
   - `LOCATION`: Sets the location for the KeyRing and CryptoKey (default: `global`).
   - `KEYRING_NAME`: Name of the KeyRing (`my-keyring`).
   - `CRYPTOKEY_NAME`: Name of the symmetric encryption key (`my-symmetric-key`).
   - File names for plaintext, encrypted, and decrypted data.

2. **Create a KeyRing**: Creates a KeyRing in the specified location.

3. **Create a CryptoKey**: Generates a symmetric encryption key within the KeyRing.

4. **Generate a Plaintext File**: Creates a sample file (`plaintext.txt`) with the message `"This is a secret message."`.

5. **Encrypt the File**: Encrypts the plaintext file and saves the output to `encrypted.txt`.

6. **Decrypt the File**: Decrypts the encrypted file and saves the output to `decrypted.txt`.

7. **Display Results**: Shows the contents of the plaintext, encrypted, and decrypted files.

8. **Clean Up (Optional)**: Deletes the generated files (`plaintext.txt`, `encrypted.txt`, `decrypted.txt`).

## How to Run
1. Save the script to a file, e.g., `kms-demo.sh`.
2. Make the script executable:
   ```bash
   chmod +x kms-demo.sh
   ```
3. Run the script:
   ```bash
   ./kms-demo.sh
   ```

