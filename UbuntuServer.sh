#Install updates
sudo apt-get update -y && sudo apt-get upgrade -y

#Install Btop and Net-Tools and NCDU
sudo apt install net-tools
sudo apt install btop
sudo apt install ncdu #Look at disk Usage with: sudo ncdu -x /

#Cleanup /usr/lib/modules and /usr/lib/x86_64-linux-gnu
sudo apt remove $(dpkg-query --show 'linux-modules-*' | cut -f1 | grep -v "$(uname -r)")

#Cleanup /var/lib/snap/cache/ and /var/log/journal
sudo bash -c 'rm /var/lib/snapd/cache/*'
sudo journalctl --vacuum-size=50M

#Cleanup unused Packages
sudo apt autoremove -y

#Install Docker and Docker-Compose
sudo apt install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" -y
sudo apt install docker-ce -y
sudo systemctl status docker

sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

