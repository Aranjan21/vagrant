#!/usr/bin/env bash
 
# BEGIN ########################################################################
echo -e "-- ------------------ --\n"
echo -e "-- BEGIN BOOTSTRAPING --\n"
echo -e "-- ------------------ --\n"
 
# VARIABLES ####################################################################
echo -e "-- Setting global variables\n"
APACHE_CONFIG=/etc/httpd/conf/httpd.conf
VIRTUAL_HOST=localhost
DOCUMENT_ROOT=/var/www/html
 
# BOX ##########################################################################
echo -e "-- Updating packages list\n"
yum update -y -qq
 
# APACHE #######################################################################
echo -e "-- Installing Apache web server\n"
yum install -y httpd
 
echo -e "-- Adding ServerName to Apache config\n"
grep -q "ServerName ${VIRTUAL_HOST}" "${APACHE_CONFIG}" || echo "ServerName ${VIRTUAL_HOST}" >> "${APACHE_CONFIG}"
 
echo -e "-- Allowing Apache override to all\n"
sed -i "s/AllowOverride None/AllowOverride All/g" ${APACHE_CONFIG}
 
echo -e "-- Updating vhost file\n"
cat > /etc/httpd/sites-enabled/000-default.conf <<EOF
<VirtualHost *:80>
    ServerName ${VIRTUAL_HOST}
    DocumentRoot ${DOCUMENT_ROOT}
 
    <Directory ${DOCUMENT_ROOT}>
        Options Indexes FollowSymlinks
        AllowOverride All
        Order allow,deny
        Allow from all
        Require all granted
    </Directory>
 
    ErrorLog ${APACHE_LOG_DIR}/${VIRTUAL_HOST}-error.log
    CustomLog ${APACHE_LOG_DIR}/${VIRTUAL_HOST}-access.log combined
</VirtualHost>
EOF
 
echo -e "-- Restarting Apache web server\n"
service httpd restart
 
# JAVA #########################################################################
echo -e "-- Installing JAVA packages\n"
yum install java-1.8.0-openjdk.x86_64 > /dev/null 2>&1
version=$(java -version)
sudo cp /etc/profile /etc/profile_backup
echo 'export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk' | sudo tee -a /etc/profile
echo 'export JRE_HOME=/usr/lib/jvm/jre' | sudo tee -a /etc/profile
source /etc/profile
echo $JAVA_HOME
 
# JENKINS #########################################################################
echo -e "-- Including Jenkins packages\n"
sudo yum install epel-release
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y -qq
 
echo -e "-- Updating packages list\n"
yum update -y -qq
echo -e "-- Installing Jenkins automation server\n"
yum install jenkins -y -qq
# NGINX ############################################################################
echo -e "--Installing NGINX Web Server\n"
sudo yum install nginx -y -qq
sudo vi /etc/nginx/nginx.conf

 
# END ##########################################################################
echo -e "-- ---------------- --"
echo -e "-- END BOOTSTRAPING --"
echo -e "-- ---------------- --"

