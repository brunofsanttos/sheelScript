#!/usr/bin/env bash

# autor: Bruno Santos <inkedin.com/in/bruno-santos-252837155/>
# descricao: Monta ambiente de desenvolvimento java no ubuntu 20.0.4
# autor: 0.1
# license: MIT LICENSE


function atualizarRepositorio(){
    echo 'Iniciando Atualização de repositorios'

    sudo apt update
    sudo apt upgrade
}

function installWget(){

    if 
        wget --version
    then 
        echo wget --version
    else
        sudo apt install wget
    fi

}

function installGoogleChome(){
    echo 'Instalando navegador Google-Chome'

    if
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    then
        cd Downloads
        sudo dpkg -i google-chrome-stable_current_amd64.deb
    fi    
}

function installIntelijcommunity(){
    echo 'Iniciando instalação intellij-idea-community'

    sudo snap install intellij-idea-community --classic
}

function installJDK11(){
    echo 'Iniciando instalação do java-jdk-11'

    sudo add-apt-repository ppa:linuxuprising/java
    sudo apt-get update
    sudo apt install oracle-java11-installer
    java --version
}

function montaAmbienteDevJava(){
    atualizarRepositorio

    if
        if
            atualizarRepositorio
        then
            installWget
        fi

    then 
        installGoogleChome

            if
                installJDK11
            then
                installIntelijcommunity
            fi    
    fi
}

montaAmbienteDevJava