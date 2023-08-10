#Install updates
sudo apt-get update -y && sudo apt-get upgrade

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

#Install Dockerand Docker-Compose
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
"deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
"$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

