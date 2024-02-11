###############################################################################
# File name: configure.sh
# Description: This script looks for webcam on system and creates docker-compose.yml file depending on it.
# Author: ovctech
# Date: February 2024
###############################################################################

#!/bin/bash

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

# Constants
TEMPLATE_DOCKER_COMPOSE="$RELATIVE_PATH/docker-compose-template.yml"
SOURCE_DOCKER_COMPOSE="$RELATIVE_PATH/docker-compose.yml"

###############################################################################

# Creating docker compose file for launch software
cp $TEMPLATE_DOCKER_COMPOSE $SOURCE_DOCKER_COMPOSE

# If webcam is detected on system
if test -n "$(find /dev -name 'video*' -print -quit)"; then
    DEVICES="- /dev/video0:/dev/video0"
fi

# Then updating docker compose file
if [ -n "$DEVICES" ]; then
    sed -i 's/# ${DEVICES}/devices/' $SOURCE_DOCKER_COMPOSE
    sed -i 's/# ${DEVICES_DASH}/-/' $SOURCE_DOCKER_COMPOSE
fi
