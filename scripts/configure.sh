###############################################################################
# File name: configure.sh
# Description: This script save state of installation in shell config (see calling script./scripts/install.sh for additional info).
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

# █████╗    █████╗    █████╗    █████╗    █████╗    █████╗    █████╗    █████╗
# ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝    ╚════╝

###############################################################################

ENV_SETUP=""

# Detect the user's shell from the SHELL environment variable
case $SHELL in
    */bash)
        # For Bash users
        ENV_SETUP="$HOME/.bashrc"
        ;;
    */zsh)
        # For Zsh users
        ENV_SETUP="$HOME/.zshrc"
        ;;
    *)
        # Default case or for other shells, you might want to choose .profile or .bashrc as a general fallback
        ENV_SETUP="$HOME/.profile"
        ;;
esac

# Check if the ENV_SETUP file exists and is not empty
if [ -n "$ENV_SETUP" ]; then
    # Append the environment variable setup to the detected shell's configuration file
    echo 'export OVCTECH_VIDEOANALYTICS_SOFTWARE_INSTALLED=true' >> "$ENV_SETUP"
    echo "${COLOR_GREEN}${TAB}${TAB}Installation flag set in $ENV_SETUP.${COLOR_CLEAR}"
    echo "${COLOR_YELLOW}${TAB}${TAB}Please restart your terminal or source the config file to apply changes.${COLOR_CLEAR}"
else
    echo "${COLOR_RED}${TAB}${TAB}${TAB}Could not determine shell configuration file to update.${COLOR_CLEAR}"
fi

read -p "${COLOR_YELLOW}${TAB}${TAB}Do you want to restart terminal? If yes - type any button${ENTER}${TAB}${TAB}Type choices: [Any button/no] ${COLOR_CLEAR}" choice
if [ "$choice" = "no" ]; then
    echo "${COLOR_YELLOW}${TAB}${TAB}Please restart your terminal later! Bye!${COLOR_CLEAR}"
else
    bash --login -c "sudo make"
fi
