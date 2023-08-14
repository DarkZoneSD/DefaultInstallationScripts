#!/bin/bash
IPprefix_by_netmask() {
    subnetcalc 1.1.1.1 "$1" -n  | sed -n '/^Netw/{s#.*/ #/#p;q}'
}

setsn ()
{
getcidrval=$(IPprefix_by_netmask "$newsn")
}

createNetplanFile ()
{
echo "network:
 version: 2
 renderer: networkd
 ethernets:
   eth0:
     dhcp4: no
     dhcp6: no
     addresses: [$newip$getcidrval]
     routes:
        - to: 0.0.0.0/0
          via: $newgw
     nameservers:
       addresses: [$newdns]" > /etc/netplan/01-eth0.yaml
}
help ()
{
echo "-n New HostName           New Hostname of the Machine"
echo "-i IPAddress              New IPAddress of the Machine"
echo "-s SubnetMask             Subnetmask of the new Network"
echo "-g Gateway                Gateway of the new Network"
echo "-d DNS                    Nameservers of the new Network, use comma to set multiple nameservers"
echo ""
echo "For Example: - sudo sh installation.sh -n NewHost -i 192.168.10.12 -s 255.255.255 -g 192.168.10.254 -d 192.168.10.254"
echo "       - sudo sh installation.sh -n HostName -i 10.0.1.10 -s 255.255.0.0 -g 10.0.0.1 -d 10.0.0.2,10.0.0.3"
}

changehostname ()
{

currenthost=$(head -n 1 /etc/hostname) #/etc/hostname
echo $newhostname > /etc/hostname #/etc/hostname
sed -i -- "s/${currenthost}/${newhostname}/g" /etc/hosts #/etc/hosts
}
##START##
failedip=1 && failedsn=1 && failedgw=1 && faileddns=1

        #Install updates
        sudo apt-get update -y && sudo apt-get upgrade -y
        #Install Btop and Net-Tools and NCDU and Subnetcalc
        sudo apt install net-tools -y
        sudo apt install btop -y
        sudo apt install ncdu -y #Look at disk Usage with: sudo ncdu -x /
        sudo apt install subnetcalc -y
        
#Configure new IP, Subnet, Gateway, DNS and HostName
while getopts :n:i:s:g:d:h flag
do
        case "${flag}" in
                n) newhostname=${OPTARG} && changehostname;;
                h) help;;
                i) newip=${OPTARG} && failedip=0;;
                s) newsn=${OPTARG} && setsn && failedsn=0;;
                g) newgw=${OPTARG} && failedgw=0;;
                d) newdns=${OPTARG} && faileddns=0;;
        esac
done
sudo rm -f /etc/netplan/50-cloud-init.yaml
if [ $failedip -eq 0 ] && [ $failedsn -eq 0 ] && [ $failedgw -eq 0 ] && [ $faileddns -eq 0 ]; then
  
        #Cleanup /usr/lib/modules and /usr/lib/x86_64-linux-gnu
        sudo apt remove $(dpkg-query --show 'linux-modules-*' | cut -f1 | grep -v "$(uname -r)")
        
        #Cleanup /var/lib/snap/cache/ and /var/log/journal
        sudo bash -c 'rm /var/lib/snapd/cache/*'
        sudo journalctl --vacuum-size=50M
        
        #Install Docker and Docker-Compose
        sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
        apt-cache policy docker-ce
        sudo apt install docker-ce -y
        
        sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        createNetplanFile
        sudo netplan apply
        echo "Your new IP Address is:\033[33;5m$newip\033[0m"
        sleep 3
        sudo shutdown -r now
else
        echo "Invalid inputs!"
        exit 1
fi
