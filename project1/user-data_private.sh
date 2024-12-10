#!/bin/bash
yum -y update
yum -y install httpd

myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
<body bgcolor="blue">
<h2><font color="red">Build by Terraform!</font></h2><br><p> 
<h2>WebServer with private IP:<font color="gray"> $myip</font></h2><br><br>
<font color="yellow"><b> Version 1.0 </b>
</body>
</html>
EOF

sudo service httpd start
chkconfig httpd on
