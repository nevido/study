	#!/usr/bash  
	yum update -y
	yum install -y httpd
	systemctl start httpd
	systemctl enable httpd
	cur http://169.254.169.254/latest/meta-data/instance-id -o /var/www/html/index.html
	