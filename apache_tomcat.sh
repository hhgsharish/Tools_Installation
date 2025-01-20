#!/bin/bash

# Function to check if the previous command was successful
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error occurred. Exiting..."
        exit 1
    fi
}

# Switch to root user
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root. Exiting..."
    exit 1
fi

# Navigate to /opt directory
cd /opt
check_success

# Download Apache Tomcat
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.34/bin/apache-tomcat-10.1.34.tar.gz
check_success

# Extract the downloaded file
tar -xvzf apache-tomcat-10.1.34.tar.gz
check_success

# Remove the tar.gz file
rm apache-tomcat-10.1.34.tar.gz
check_success

# Update the port number in server.xml
sed -i 's/<Connector port="8080" protocol="HTTP\/1.1"/<Connector port="8082" protocol="HTTP\/1.1"/' /opt/apache-tomcat-10.1.34/conf/server.xml
check_success

# Comment out Valve lines in context.xml for manager and host-manager
sed -i 's/<Valve className="org.apache.catalina.valves.RemoteAddrValve".*/<!-- & -->/' /opt/apache-tomcat-10.1.34/webapps/manager/META-INF/context.xml
check_success
sed -i 's/<Valve className="org.apache.catalina.valves.RemoteAddrValve".*/<!-- & -->/' /opt/apache-tomcat-10.1.34/webapps/host-manager/META-INF/context.xml
check_success

# Add user credentials to tomcat-users.xml
cat <<EOL >> /opt/apache-tomcat-10.1.34/conf/tomcat-users.xml
<!-- user manager can access only manager section -->
<role rolename="manager-gui" />
<user username="manager" password="1234" roles="manager-gui" />

<!-- user admin can access manager and admin section both -->
<role rolename="admin-gui" />
<user username="admin" password="1234" roles="manager-gui,admin-gui" />
EOL
check_success

# Start and stop scripts for Tomcat
cat <<EOL > /opt/apache-tomcat-10.1.34/bin/start-tomcat.sh
#!/bin/bash
/opt/apache-tomcat-10.1.34/bin/startup.sh
EOL

cat <<EOL > /opt/apache-tomcat-10.1.34/bin/stop-tomcat.sh
#!/bin/bash
/opt/apache-tomcat-10.1.34/bin/shutdown.sh
EOL

chmod +x /opt/apache-tomcat-10.1.34/bin/startup.sh /opt/apache-tomcat-10.1.34/bin/shutdown.sh

# Completion message
echo "Apache Tomcat installation and setup completed successfully."
echo "To start Tomcat: /opt/apache-tomcat-10.1.34/bin/startup.sh"
echo "To stop Tomcat: /opt/apache-tomcat-10.1.34/bin/shutdown.sh"
