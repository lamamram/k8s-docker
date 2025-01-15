# install java jdk 17
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk

# TLS jenkins cert
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=jenkins.myusine.fr"
openssl pkcs12 -export -in tls.crt -inkey tls.key -out keystore.p12 -name jenkins -CAfile tls.crt -caname root -password pass:password
keytool -importkeystore -deststorepass password -destkeypass password -destkeystore keystore.jks -srckeystore keystore.p12 -srcstoretype PKCS12 -srcstorepass password -alias jenkins
mv keystore.jks ~/jenkins/certs/

# Install Mailhog: FAKE SMTP
wget https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
sudo mv MailHog_linux_amd64 /usr/local/bin/mailhog
sudo chmod +x /usr/local/bin/mailhog

sudo mv mailhog.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable mailhog
sudo systemctl start mailhog

## pour utiliser: SMTP sur le port 1025
## //   vister: http://jenkins.lan:8025