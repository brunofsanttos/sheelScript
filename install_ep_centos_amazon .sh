#!bin/bash

function installGeneralApplications() {

	echo Removing old JDKs
	sudo yum remove openjdk*
	sudo yum remove --auto-remove openjdk*
	sudo yum purge openjdk*
	sudo yum purge --auto-remove openjdk*


	echo Installing xclip
	wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	sudo rpm -ivh epel-release-latest-7.noarch.rpm
	sudo yum-config-manager --enable epel
	sudo yum install xclip -y
	echo Installing git
	sudo yum install git


	
	echo Installing NVM
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
	echo '' >> ~/.bashrc
	echo '[[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh  # This loads NVM' >> ~/.bashrc
	source ~/.bashrc
	echo Installing NODE 9.5.0
	nvm install 9.5.0
	echo Installing GRUNT CLI
	npm install -g grunt-cli


	echo Installing Sublime Text - text editor
	wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
	sudo yum install apt-transport-https
	echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
	sudo yum update
	sudo rpm -v --import https://download.sublimetext.com/sublimehq-rpm-pub.gpg
sudo wget -P /etc/yum.repos.d/ https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo
sudo dnf install sublime-text
sudo yum install sublime-text
}

function installJdk() {
	#Descompactar MAVEN e TOMCAT
	echo Creating Development folder and unziping tomcat and maven
	mkdir ~/Development
	unzip ~/Downloads/apache-tomcat-7.0.59.zip -d ~/Development
	unzip ~/Downloads/apache-maven-3.0.5.zip -d ~/Development


	#Instalar JDK 1.7 build 79
	echo Unpacking jdk 1.7 and creating symbolic links
	sudo mkdir /opt/java
	sudo tar -xzvf ~/Downloads/jdk-7u79-linux-x64.tar.gz -C /opt/java
	sudo tar -xzvf ~/Downloads/jdk-8u241-linux-x64.tar.gz -C /opt/java
	ln -s /opt/java/jdk1.7.0_79/ jdk7

	echo Add environment variable to bashrc
	#Inserir dados to arquivo bashrc 
	echo '' >> ~/.bashrc
	echo '' >> ~/.bashrc
	echo 'export MAVEN_HOME=/home/${USER}/Development/apache-maven-3.0.5' >> ~/.bashrc
	echo 'export PATH=$PATH:$MAVEN_HOME/bin' >> ~/.bashrc
	echo 'export JAVA_HOME="/opt/java/jdk1.7.0_79"' >> ~/.bashrc
	echo 'export CLASSPATH="$JAVA_HOME/lib":$CLASSPATH' >> ~/.bashrc
	echo 'export PATH="$JAVA_HOME/bin":$PATH' >> ~/.bashrc
	echo 'export MANPATH="$JAVA_HOME/man":$MANPATH' >> ~/.bashrc
	echo '' >> ~/.bashrc
	echo 'export MAVEN_OPTS='\''-Xmx1024m -XX:MaxPermSize=512m -XX:ReservedCodeCacheSize=128m -Dsun.lang.ClassLoader.allowArraySyntax=true -ea'\''' >> ~/.bashrc
	source ~/.bashrc

	echo Downloading jdk certificates
	wget https://thawte.tbs-certificats.com/Thawte_TLS_RSA_CA_G1.crt -O ~/Downloads/Thawte_TLS_RSA_CA_G1.crt
	wget https://www.tbs-certificats.com/issuerdata/DigiCert_Global_Root_G2.crt -O ~/Downloads/DigiCert_Global_Root_G2.crt 
	sudo $JAVA_HOME/jre/bin/keytool -import -trustcacerts -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -file ~/Downloads/Thawte_TLS_RSA_CA_G1.crt -alias thawte
	sudo $JAVA_HOME/jre/bin/keytool -import -trustcacerts -keystore $JAVA_HOME/jre/lib/security/cacerts -storepass changeit -noprompt -file ~/Downloads/DigiCert_Global_Root_G2.crt -alias digi

}



function generateGitKeys() {


	#Gerar Chave GIT 
	#Referencia: https://docs.github.com/pt/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
	ssh-keygen -t ed25519 -C "user@wine.com.br"
	eval "$(ssh-agent -s)"
	ssh-add ~/.ssh/id_ed25519
	xclip -selection clipboard < ~/.ssh/id_ed25519.pub



	echo ********************************************
	echo ********************************************
	echo ********************************************
	echo Insira a chave no GITHUB manualmente
	echo Referencia: https://docs.github.com/pt/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
	echo ********************************************
	echo ********************************************
	echo ********************************************
	echo ********************************************

}

function downloadAndInstallCommerce() {
	echo Deleting folder /ep-assets
	sudo rm -rf /ep-assets
	echo Deleting folder ~/ep
	rm -rf ~/ep
	echo Deleting folder ~/Development/workspace
	rm -rf ~/Development/workspace
	echo Creating folder /ep-assets
	sudo mkdir /ep-assets
	echo Granting chown permission to folder /ep-assets
	sudo chown $USER /ep-assets
        echo Creating and cloning wine-utils
        cd ~/Development/
        git clone git@github.com:winecombr/wine-utils.git
        sudo yum install python
	echo Creating folder ~/Development/workspace
	mkdir ~/Development/workspace 
	cd ~/Development/workspace
	git clone git@github.com:winecombr/wine.git
	cd ~/Development/workspace/wine
	git submodule init
	git submodule update --init --recursive

	echo Creating folder ~/.m2
	mkdir ~/.m2
	rm ~/.m2/settings.xml
	echo Copying settings.xml file from ~/Development/workspace/wine/giran/env-configs/settings.xml to ~/.m2
	cp ~/Development/workspace/wine/giran/env-configs/settings.xml ~/.m2

	mkdir ~/ep
	echo Copying settings.xml file from ~/Development/workspace/wine/giran/env-configs/dev/ep.properties to ~/ep
	cp ~/Development/workspace/wine/giran/env-configs/dev/ep.properties ~/ep
	echo Copying settings.xml file from ~/Development/workspace/wine/giran/env-configs/dev/redisson.json to ~/ep
	cp ~/Development/workspace/wine/giran/env-configs/dev/redisson.json ~/ep

	cd ~/Development/workspace/wine/commerce-engine/
	pwd
	echo Building ~/Development/workspace/wine/commerce-engine/
	#mvn clean install -DskipAllTests
	mvn clean install -DskipAllTests
	cd ~/Development/workspace/wine/commerce-engine/jms 
	pwd
	echo ~/Development/workspace/wine/commerce-engine/jms 
	mvn clean install -DskipAllTests 
	cd ~/Development/workspace/wine/bigw 
	pwd
	echo Building ~/Development/workspace/wine/bigw
	mvn clean install -DskipAllTests 
	cd ~/Development/workspace/wine/extensions/ext-assets 
	pwd 
	echo ~/Development/workspace/wine/extensions/ext-assets 
	mvn clean install -DskipAllTests
	cd ~/Development/workspace/wine/extensions/stores/wine-assets/src/main/assets/frontend
	npm run gcp-auth
	cd ~/Development/workspace/wine/extensions/stores/wine-assets 
	pwd
	echo Building ~/Development/workspace/wine/extensions/stores/wine-assets 
	mvn clean install -DskipAllTests
	cd ~/Development/workspace/wine/extensions 
	pwd  
	echo Building ~/Development/workspace/wine/extensions 
	mvn clean install -DskipAllTests
	echo '' >> ~/.bashrc
        echo 'alias build='\''cd /home/${USER}/Development/workspace/wine/bigw; pwd; mvn clean install -DskipAllTests -T4;cd /home/${USER}/Development/workspace/wine/extensions; pwd; mvn clean install -DskipAllTests -T4'\''' >> ~/.bashrc
}

function installDocker() {


unzip ~/Downloads/banco_ep_docker.zip -d ~/Development

sudo yum remove docker docker-engine docker.io containerd runc
sudo yum update
sudo yum install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic test"
sudo yum update

sudo yum install docker-ce docker-ce-cli containerd.io

sudo docker run hello-world

sudo chown "$USER":"$USER" /home/"$USER"/.docker -R
sudo chmod g+rwx "$HOME/.docker" -R
sudo chmod 666 /var/run/docker.sock

sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user

}