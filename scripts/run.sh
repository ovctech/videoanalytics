###############################################################################
# File name: run.sh
# Description: Start application if dependicies are installed, if not - install them by user choice and then run app.
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

# Check if the OVCTECH_VIDEOANALYTICS_SOFTWARE_INSTALLED environment variable is set to true
if [ "$OVCTECH_VIDEOANALYTICS_SOFTWARE_INSTALLED" = "true" ]; then
    echo "${COLOR_GREEN}${TAB}Installation state verified. Proceeding to run the application.${COLOR_CLEAR}"
else
    echo "${COLOR_RED}${TAB}The software does not appear to be installed.${COLOR_CLEAR}"
    read -p "${COLOR_YELLOW}${TAB}Would you like to install the software dependicies now? If yes - type yes${ENTER}${TAB}${TAB}Type choices: [Any button/yes] ${COLOR_CLEAR}" answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
    if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
        bash $RELATIVE_PATH/scripts/install.sh
    else
        echo "${COLOR_RED}${TAB}Installation aborted. Exiting.${COLOR_CLEAR}"
        exit 1
    fi
fi

###############################################################################

# Run application if dependicies are already installed
sudo make
sleep 3
if test -n "$(find /dev -name 'video*' -print -quit)"; then
    echo "Webcam found!"
    open http://127.0.1.1:8000/video_feed/
else
    echo "No webcam found."
    open http://127.0.1.1:8000/video_feed/?camera_url=do_not_have_webcam__if_have_dont_parametize__just_video_feed_slash
fi
