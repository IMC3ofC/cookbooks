# Set the systems authentication to SHA-512
authconfig --passalgo=sha512 --update



# Update sudoers file
sed -i 's/^Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers

# Create OS user groups used by the BigInsights product
/usr/sbin/groupadd -f bisysadmin
/usr/sbin/groupadd -f bidataadmin
/usr/sbin/groupadd -f biappadmin
/usr/sbin/groupadd -f biuser
/usr/sbin/groupadd -f biadmin

# Create and configure biadmin user

/usr/sbin/useradd -u 1001 -G biuser,bisysadmin,bidataadmin,biappadmin -g biadmin biadmin
echo "$BIADMIN_PASSWORD" | passwd --stdin biadmin

[[ -e /home/biadmin/.ssh/ ]] && mv /home/biadmin/.ssh/ /home/biadmin/.ssh_old
cp -R /root/.ssh/ /home/biadmin/
chown -R biadmin:biadmin /home/biadmin/.ssh/
ls -la /home | grep biadmin
ls -la /home/biadmin | grep .ssh
ls -la /home/biadmin/.ssh
ls -la /root | grep .ssh

# Add biadmin as passwordless sudoer
echo 'biadmin ALL=(ALL)       NOPASSWD:ALL' >> /etc/sudoers
