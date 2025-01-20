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

# Install the latest Java (OpenJDK)
sudo apt install openjdk-17-jdk -y
check_success

# Verify Java installation
java -version
check_success

# Install Maven
sudo apt install maven -y
check_success

# Verify Maven installation
mvn -version
check_success

# Completion message
echo "Java and Maven installation completed successfully."
