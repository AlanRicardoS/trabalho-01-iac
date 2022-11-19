export DEBIAN_FRONTEND=noninteractive
sudo apt update -y
sudo apt install apache2 -yq
sudo apt install ufw -yq
sudo ufw app list 
sudo ufw allow in "Apache" 
sudo ufw status
#ip addr show ens3 | grep inet | awk '{ print $2; }' | sed 's/\/.*$//'
sudo apt install mysql-server -yq
sudo apt install php libapache2-mod-php php-mysql -yq
sudo mkdir /var/www/iac
sudo chown -R $USER:$USER /var/www/iac
#sudo nano /etc/apache2/sites-available/iac.conf
#sudo a2ensite iac
#sudo a2dissite 000-default
#sudo apache2ctl configtest
#sudo systemctl reload apache2
#touch /var/www/iac/index.html
#echo '<html>
#  <head>
#    <title>your_domain website</title>
#  </head>
#  <body>
#    <h1>Hello World!</h1>
#
#    <p>This is the landing page of <strong>your_domain</strong>.</p>
#  </body>
#</html>' > /var/www/iac/index.html
