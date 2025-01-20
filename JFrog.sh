#!/bin/bash

# Function to check if the previous command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred. Exiting..."
        exit 1
    fi
}

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Exiting..."
    exit 1
fi

# Update and upgrade the system
sudo apt update
check_success
sudo apt upgrade -y
check_success

# Install PostgreSQL
sudo apt install postgresql postgresql-contrib -y
check_success

# Check PostgreSQL status
sudo systemctl status postgresql

# Switch to postgres user and configure the database
sudo -i -u postgres bash <<EOF
# Create user and database
createuser --interactive --pwprompt <<USER_INPUT
artifactory
password
n
USER_INPUT
createdb artifactory_db
# Grant permissions
psql -c "GRANT ALL PRIVILEGES ON DATABASE artifactory_db TO artifactory;"
exit
EOF
check_success

# Install JFrog Artifactory
echo "deb https://releases.jfrog.io/artifactory/artifactory-debs xenial main" | sudo tee -a /etc/apt/sources.list.d/artifactory.list
check_success
curl -fsSL https://releases.jfrog.io/artifactory/api/gpg/key/public | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/artifactory.gpg
check_success

# Install Artifactory package
sudo apt update
check_success
sudo apt install jfrog-artifactory-oss -y
check_success

# Configure Artifactory to use PostgreSQL
cat <<EOL > /var/opt/jfrog/artifactory/etc/system.yaml
shared:
  database:
    type: postgresql
    driver: org.postgresql.Driver
    url: jdbc:postgresql://localhost:5432/artifactory_db
    username: artifactory
    password: password
EOL
check_success

# Start and check Artifactory service
sudo systemctl start artifactory
check_success
sudo systemctl status artifactory

# Display completion message
echo "JFrog Artifactory installation and configuration completed."
echo "Access Artifactory at: http://<EC2_Public_IP>:8081"
