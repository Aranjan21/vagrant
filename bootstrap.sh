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
yum install -y openjdk-8-jre > /dev/null 2>&1
yum install -y openjdk-8-jdk > /dev/null 2>&1
 
# JENKINS #########################################################################
echo -e "-- Including Jenkins packages\n"
wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add - > /dev/null 2>&1
sh -c "echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list"
 
echo -e "-- Updating packages list\n"
yum update -y -qq
echo -e "-- Installing Jenkins automation server\n"
yum install jenkins -y -qq
 
# END ##########################################################################
echo -e "-- ---------------- --"
echo -e "-- END BOOTSTRAPING --"
echo -e "-- ---------------- --"

