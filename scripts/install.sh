###############################################################################
# File name: install.sh
# Description: This script performs a full installation of software on a clean Ubuntu system and save state of installation (see ./scripts/configure.sh).
# Author: ovctech
# Date: February 2024
###############################################################################

#!/bin/bash

###############################################################################

# Constants for printing
OS=$(uname)
if [ "$OS" = "Linux" ]; then
    COLOR_RED=$(tput setaf 1)
    COLOR_GREEN=$(tput setaf 2)
    COLOR_YELLOW=$(tput setaf 3)
    COLOR_CLEAR=$(tput sgr0)
else
    COLOR_RED="\033[31m"
    COLOR_GREEN="\033[32m"
    COLOR_YELLOW="\033[33m"
    COLOR_CLEAR="\033[0m"
fi
TAB=$'\t'
ENTER=$'\n'

###############################################################################

# Check if the current directory is named "scripts"
RUNNING_FROM=$(basename "$PWD")
if [ "$RUNNING_FROM" == "scripts" ]; then
    RELATIVE_PATH=".."
else
    RELATIVE_PATH="."
fi

###############################################################################

# █████╗    █████╗    █████╗    █████╗    █████╗    █████╗    █████╗    █████╗
# ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝

###############################################################################


# Get list of packages names for further variable installation
mapfile -t PROJECT_PACKAGES_NAMES < "$RELATIVE_PATH/packages/packages.txt"

###############################################################################

# Package installation block
echo "${COLOR_YELLOW}${TAB}Installing Project Prerequisites on system...${COLOR_CLEAR}"
echo "${COLOR_YELLOW}${TAB}${TAB}Installing Project Deb Prerequisites on system online...${COLOR_CLEAR}"
for package in "${PROJECT_PACKAGES_NAMES[@]}"; do
    echo "${COLOR_GREEN}${TAB}${TAB}${TAB}Installing $package...${COLOR_CLEAR}"
    if ! sudo apt install -y "$package"; then
        echo "${COLOR_RED}${TAB}${TAB}${TAB}Failed to install "$package"${COLOR_CLEAR}"
    fi
done
echo "${COLOR_GREEN}${TAB}Installing Project Prerequisites on system finished successfully!${COLOR_CLEAR}"


###############################################################################

# Copy figlet fonts to system
sudo cp $RELATIVE_PATH/templates/fonts/* $(figlet -I 2)

echo -e "\\n\\n\\n"
figlet -c -t -f "ANSI Shadow" READY TO START!
echo -e "\\n\\n\\n"

###############################################################################

# Save installation state
bash $RELATIVE_PATH/scripts/configure.sh
