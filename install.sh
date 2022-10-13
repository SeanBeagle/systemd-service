#!/usr/bin/bash

### DONT TOUCH #############################################
script_dir="$(dirname ${0})"                               #
source "${script_dir}/.env"                                #
source_dir="${script_dir}/src"                             #
bin_dir="/opt/${product_line}/${service}"                  #
config_dir="/etc/${product_line}/${service}"               #
service_file="/usr/lib/systemd/system/${service}.service"  #
service_file_link="/etc/systemd/system/${service}.service" #
############################################################


uninstall() {
    # STOP AND REMOVE OLD SYSTEMD SERVICE
    sudo systemctl stop ${service}
    sudo systemctl disable ${service}
    sudo rm -f ${service_file_link}
    sudo rm -f ${servivce_file}
    # REMOVE OLD BINARIES
    rm -rf ${bin_dir}
}

install() {
    #### INSTALL SYSTEMD SERVICE FILE
    ##   Installs the systemd service file to /usr/lib/systemd/system,
    ##   removes any old symbolic links, and creates a symbolic link in /etc/systemd/system
    sudo install -o root -g root -m 644 ${source_dir}/systemd.service ${service_file}
    sudo rm -f ${service_file_link}
    sudo ln -s ${service_file} /etc/systemd/system/
    
    
    ##### UPDATE VARIABLES IN SYSTEMD SERVICE FILE
    ##    Variables in the systemd.service file use the format: {VARIABLE}
    ##    and are replaced with environment variables declared above.
    sudo sed -i "s#{CONFIG_DIR}#${config_dir}#" ${service_file}
    sudo sed -i "s#{BIN_DIR}#${bin_dir}#" ${service_file}
    sudo sed -i "s#{DESCRIPTION}#${description}#" ${service_file}
    sudo sed -i "s#{SERVICE}#${service}#" ${service_file}
    

    #### INSTALL SERVICE BINARIES
    ##   This example is for a python service that uses main.py as it's ingress
    sudo mkdir -p ${bin_dir}
    sudo cp -r ${source_dir}/* ${bin_dir}
    sudo chmod 775 ${bin_dir}/main.py
    sudo ln -s ${bin_dir}/main.py ${bin_dir}/${service}
    
    #### CREATE CONFIGURATION DIRECTORY
    ##   Creates a config directory in /etc for storing service resources
    ##   This directory acts as the working directory for the service so that
    ##   absolute paths are not required to access resources.
    sudo mkdir -p ${config_dir}
    sudo install -o root -g root -m 644 ${source_dir}/config.json ${config_dir}/config.json
}

start() {
    sudo systemctl daemon-reload
    sudo systemctl enable ${service}
    sudo systemctl start ${service}
}

main() {
    uninstall
    install
    start
}

main
