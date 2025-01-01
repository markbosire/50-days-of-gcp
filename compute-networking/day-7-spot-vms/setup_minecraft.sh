#!/bin/bash

# Step 1: Create the firewall rule to allow SSH and Minecraft server traffic
echo "Creating firewall rule..."
gcloud compute firewall-rules create minecraft-firewall \
    --allow=tcp:22,tcp:25565 \
    --target-tags=minecraft-server \
    --description="Allow SSH and Minecraft server traffic" \
    --direction=INGRESS \
    --priority=1000 \
    --network=default

# Step 2: Create the minecraft-startup.sh script
echo "Creating minecraft-startup.sh script..."
cat <<EOL > minecraft-startup.sh
#!/bin/bash

# Update package list and install Java dependencies
apt-get update && apt-get install -y java-common

# Download and install Amazon Corretto JDK (Java Development Kit)
curl -L https://corretto.aws/downloads/latest/amazon-corretto-21-x64-linux-jdk.deb -o jdk.deb
dpkg --install jdk.deb

# Clean up unnecessary files after JDK installation
rm -f jdk.deb

# Create the Minecraft server directory and navigate into it
mkdir -p /minecraft-server
cd /minecraft-server

# Download the official Minecraft server JAR file
curl -L https://piston-data.mojang.com/v1/objects/4707d00eb834b446575d89a61a11b5d548d8c001/server.jar -o server.jar

# Automatically accept the Minecraft EULA
echo 'eula=true' > eula.txt

# Start the Minecraft server with specified memory limits and no graphical interface
java -Xmx1024M -Xms1024M -jar server.jar nogui

# Cleanup downloaded server JAR file after server startup
rm -f server.jar
EOL

# Step 3: Create the VM instance with the startup script
echo "Creating the VM instance..."
gcloud compute instances create minecraft-server \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --tags=minecraft-server \
    --provisioning-model=SPOT \
    --metadata-from-file=startup-script=minecraft-startup.sh

# Step 4: Wait for the server to initialize
echo "Waiting for the server to initialize..."
sleep 60

# Step 5: Check the Minecraft server status
echo "Checking the Minecraft server status..."
curl -X GET "https://api.mcstatus.io/v2/status/java/$(gcloud compute instances list --filter='name:minecraft-server' --format='get(networkInterfaces[0].accessConfigs[0].natIP)')"

# Step 6: Cleanup VM and firewall rule
# gcloud compute firewall-rules delete minecraft-firewall --quiet
# gcloud compute firewall-rules delete minecraft-firewall --quiet

echo "Setup complete"

