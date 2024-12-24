#!/bin/bash
# Update package list and install Nginx
apt update -y
apt install nginx -y

# Create a custom HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>100 days of gcp start a web server with terraform</title>
</head>
<body>
    <h1>Welcome to the 100 days of gcp page</h1>
    <p>This is a static website hosted on Nginx.</p>
</body>
</html>
EOF

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx
