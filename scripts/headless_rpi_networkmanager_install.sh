#!/usr/bin/env bash

echo "This script is will install NetworkManager on a headless (wifi) connected Raspberry pi zero."
echo "It verifies NetworkManager is installed."
echo "If not, installs it (and in the process disables the dhcpcd service)"
echo ""

check_os_version () {
    if [[ "$OSTYPE" != "linux"* ]]; then
        echo "ERROR: This application only runs on Linux."
        exit 1
    fi

    local _version=""
    if [ -f /etc/os-release ]; then
        _version=$(grep -oP 'VERSION="\K[^"]+' /etc/os-release)
    fi
    if [ "$_version" != "11 (bullseye)" ]; then
        echo "ERROR: Distribution not based on Raspbian 11 (bullyeye)."
        exit 1
    fi
}

install_network_manager () {
    echo "Updating Raspberry pi package list..."
    apt-get -y update

    echo "Downloading and installing NetworkManager..."
    apt-get install -y network-manager
    
    echo "enabling Network Manager"
    systemctl enable NetworkManager
    echo "disabling dhcpcd..."
    systemctl disable dhcpcd

    # sleeping for 30 seconds
    echo "Sleeping 30 seconds to push process into background"
    echo " and allow wifi to drop: use ctrl+z (get job#), bg %job#, disown %job#"
    /bin/sleep 30

    echo "Stopping dhcpcd..."
    systemctl stop dhcpcd
    
    echo "starting Network Manager"
    systemctl start NetworkManager
    echo " sleeping 15 seconds to allow Network Manager to collect SSID"
    /bin/sleep 15
    echo "now add the wifi command"
    nmcli dev wifi connect SSID password "SSID password"
    
    # logging into 

    #echo "Installing NetworkManager..."
    #apt-get install -y network-manager
    #apt-get clean
}

# This only works on Linux raspberry 11 (bullseye) 
check_os_version

# Confirm the user wants to install...
#read -r -p "Do you want to install? [y/N]: " response
#response=${response,,}  # convert to lowercase
#if [[ ! $response =~ ^(yes|y)$ ]]; then
#    exit 0
#fi

# Update packages and install
install_network_manager
