#!/bin/bash

# Function to check if the previous command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred. Exiting..."
        exit 1
    fi
}

# Add Jenkins keyring
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
check_success

# Add Jenkins repository
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
check_success

# Update system packages
sudo apt-get update
check_success

# Install Jenkins
sudo apt-get install -y jenkins
check_success

# Install dependencies
sudo apt update
check_success
sudo apt install -y fontconfig openjdk-17-jre
check_success

# Enable and start Jenkins service
sudo systemctl enable jenkins
check_success
sudo systemctl start jenkins
check_success

# Check Jenkins status
sudo systemctl status jenkins

# Add Jenkins to sudoers file
sudo bash -c 'echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
check_success

# Reload bash configuration
source ~/.bashrc
check_success

# Completion message
echo "Jenkins installation and setup completed successfully."
