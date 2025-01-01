# Minecraft Server Setup Script

This script sets up a Minecraft server on a Google Cloud VM, including the creation of a firewall rule to allow SSH and Minecraft traffic. The server uses Amazon Corretto JDK and installs Minecraft server dependencies.

## Steps
1. **Create Firewall Rule**: Opens ports 22 (SSH) and 25565 (Minecraft) for the server.
2. **Setup Minecraft Server**: Installs Java, downloads Minecraft server, accepts EULA, and starts the server.
3. **VM Creation**: Launches a VM with the startup script to run the Minecraft server.
4. **Server Status**: Waits for the server to initialize and checks the server status via an API.

## Cleanup
After the server is set up, you can clean up the created resources using the following commands:

```bash
# Delete the firewall rule
gcloud compute firewall-rules delete minecraft-firewall --quiet

# Delete the VM instance
gcloud compute instances delete minecraft-server --quiet
