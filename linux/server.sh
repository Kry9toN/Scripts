#!/usr/bin/env bash

while true; do
    read -p "You want to Persistant disk ? : " yn
    case $yn in
        [Yy]* )
            # Format and setup
            echo "***** Prepare Persistant Disk path:/mnt/build *****  ";
            sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb;
            sudo mkdir -p /mnt/build;
            sudo mount -o discard,defaults /dev/sdb /mnt/build;
            sudo chmod a+w /mnt/build;
            sudo cp /etc/fstab /etc/fstab.backup;
            echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /mnt/build ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab;
            cat /etc/fstab; break;;
        [Nn]* ) break;;
        * ) echo "Please answer y or n.";;
    esac
done

echo " "
echo "***** Setup ZSH *****"
sudo apt install git ccache wget zsh -y
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cd $HOME/.oh-my-zsh/plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions
cd $HOME
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' $HOME/.zshrc
sed -i 's/plugins=(git)/plugins=(git repo)/g' $HOME/.zshrc
echo "source $HOME/.oh-my-zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> $HOME/.zshrc
echo "source $HOME/.oh-my-zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> $HOME/.zshrc
sleep 1s

echo "***** Enviroment setup.. *****"
sudo git config --global user.name "Kry9toN"
sudo git config --global user.email "dhimasbagusprayoga@gmail.com"
sudo /usr/sbin/update-ccache-symlinks
echo 'export PATH="/usr/lib/ccache:$PATH"' | tee -a ~/.bashrc
source ~/.bashrc && echo $PATH
sleep 1s

echo "***** Clone AkhilNarang ENV script *****"
git clone https://github.com/akhilnarang/scripts
echo "***** Entering path:/home/"$(whoami)"/scripts/"
cd scripts || exit 1
sudo bash setup/android_build_env.sh
cd ..
sleep 1s

echo "***** Install jenkins *****"
echo "Install Open JDK, Jenkins and Apache"
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian binary/ > \
    /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt install jenkins apache2 -y
# a2enmod
echo "Enable modul apache and restart service apache"
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2ensite jenkins
sleep 1s

# then start both apache and jenkins
echo "Start service apache and jenkins"
sudo systemctl start apache2
sudo systemctl start jenkins
sleep 1s

# add Jenkins web apache2 config
echo "adding and symlinking config /etc/apache2/sites-available/jenkins"
sudo wget https://raw.githubusercontent.com/Komodo-OS-Rom/Server_Utilites/master/apache2/jenkins.conf -P /etc/apache2/sites-available/
sudo chmod 644 /etc/apache2/sites-available/jenkins.conf
sleep 1s

sudo systemctl restart apache2
sudo systemctl restart jenkins
sleep 1s

echo "***** Install gerrit *****"
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt install certbot python3-certbot-apache -y
sudo adduser gerrit --gecos "" --disabled-password
echo "gerrit:gerrit" | sudo chpasswd
sudo -u gerrit -H sh -c "cd $HOME; wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate 'https://docs.google.com/uc?export=download&id=1eV2q-YpOSwMaFyoyeKqxjq-HJpgWRy7l' -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')&id=1eV2q-YpOSwMaFyoyeKqxjq-HJpgWRy7l" -O gerrit.zip && rm -rf /tmp/cookies.txt; unzip gerrit.zip; sed -i 's/8080/2222/g' $HOME/gerrit/etc/gerrit.config; $HOME/gerrit/bin/gerrit.sh start; "

echo "***** Setup apache2 for gerrit *****"
sudo wget https://raw.githubusercontent.com/Komodo-OS-Rom/Server_Utilites/master/apache2/gerrit.conf -P /etc/apache2/sites-available/
sudo chmod 644 /etc/apache2/sites-available/gerrit.conf
sleep 1s

sudo a2ensite gerrit
sudo systemctl restart apache2
sleep 1s

while true; do
    read -p "Have you recorded A this server's public IP ? : " yn
    case $yn in
        [Yy]* ) sudo certbot --apache; break;;
        [Nn]* ) echo "Please first record the this public ip server!";;
        * ) echo "Please answer y or n.";;
    esac
done
sleep 1s

exit
