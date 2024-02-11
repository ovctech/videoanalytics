###############################################################################
# File name: Makefile
# Description: The Makefile is used to define and run tasks for the "videoanalytics" project.
#			   It includes settings for the Python version, project structure, and commands
# 			   for managing this fullstack project.
# Author: ovctech
# Date: February 2024
###############################################################################

# Settings:
# ------------------------------
PYTHON_V := 3.11.0
TARGET := videoanalytics

PROJECT_ROOT := $(abspath .)

# Docker
DOCKER_COMPOSE_BACKEND := docker-compose.yml

# Scripts settings:
SCRIPTS_DIR := scripts

# Frontend settings:
FRONTEND_DIR := $(TARGET)/frontend
FRONTEND_IMAGES_DIR := images
FRONTEND_PACKAGES_DIR := packages
FRONTEND_ROOT := $(PROJECT_ROOT)/$(FRONTEND_DIR)
FRONTEND_IMAGES_ROOT := $(FRONTEND_ROOT)/$(FRONTEND_IMAGES_DIR)
FRONTEND_PACKAGES_ROOT := $(FRONTEND_ROOT)/$(FRONTEND_PACKAGES_DIR)
FRONTEND_IMAGES := $(wildcard $(FRONTEND_IMAGES_ROOT)/*.tar)
FRONTEND_PACKAGES := $(wildcard $(FRONTEND_PACKAGES_ROOT)/*.deb)

# Backend settings:
BACKEND_DIR := $(TARGET)/backend
BACKEND_IMAGES_DIR := images
BACKEND_PACKAGES_DIR := packages
BACKEND_ROOT := $(PROJECT_ROOT)/$(BACKEND_DIR)
BACKEND_IMAGES_ROOT := $(BACKEND_ROOT)/$(BACKEND_IMAGES_DIR)
BACKEND_PACKAGES_ROOT := $(BACKEND_ROOT)/$(BACKEND_PACKAGES_DIR)
BACKEND_IMAGES := $(wildcard $(BACKEND_IMAGES_ROOT)/*.tar)
BACKEND_PACKAGES := $(wildcard $(BACKEND_PACKAGES_ROOT)/*.deb)
BACKEND_PACKAGES_NAMES := $($(BACKEND_PACKAGES_ROOT)/*.txt)

# Colors (for terminal output):
OS = $(shell uname)
ifeq ($(OS), Linux)
	COLOR_RED = $(shell tput setaf 1)
	COLOR_GREEN = $(shell tput setaf 2)
	COLOR_YELLOW = $(shell tput setaf 3)
	COLOR_CLEAR = $(shell tput sgr0)
else
	COLOR_RED = \033[31m
	COLOR_GREEN = \033[32m
	COLOR_YELLOW = \033[33m
	COLOR_CLEAR = \033[0m
endif
TAB := $(shell printf '\t')
define ENTER


endef

# ------------------------------------------------------------------------------------------------------------------------
# Main commands: (USAGE >> make TARGET_NAME)
# It supposed that you will use only commands of this block ( Main commands)
# ------------------------------
.PHONY: all launch frebuild stop silent-stop back-logs back-deep-logs back-sh deploy-backend

# General:
all: check silent-stop run-app # Launch videoanalytics (EXAMPLE USAGE>> make )

launch: silent-stop run-app # Launch videoanalytics without user choice to stop containers (EXAMPLE USAGE>> make launch)

frebuild: fclean load-app run-app # BECARE: Completly delete images and load them after, then launch videoanalytics (EXAMPLE USAGE>> make frebuild)

# Stop:
stop: stop-containers # Stop videoanalytics (EXAMPLE USAGE>> make stop )

silent-stop: stop-containers-without-read # Stop videoanalytics without user choice (EXAMPLE USAGE>> make silent-stop )

# Logs:
back-logs: see-backend-logs # To see backend logs (EXAMPLE USAGE>> make back-logs)

back-deep-logs: see-backend-deep-logs # To see backend logs (EXAMPLE USAGE>> make back-deep-logs)

back-sh: get-inside-backend # To get into backend (EXAMPLE USAGE>> make back-sh)

# ------------------------------------------------------------------------------------------------------------------------

# Run App:
# ------------------------------
.PHONY: run-app

run-app: figlet-launch compose-up-script


# Sub commands:
# ------------------------------
.PHONY: figlet-launch compose-up-script see-backend-logs stop-containers fclean stop-containers-without-read get-inside-backend ffclean check

figlet-launch:
	@echo "\n\n\n"
	@figlet -c -t -f "ANSI Shadow" Launch app...
	@echo "\n\n\n"

get-inside-backend:
	@echo "$(COLOR_YELLOW)$(TAB)Backend container sh...$(COLOR_CLEAR)"
	@export CONTAINER_ID=$$(sudo docker ps -q --filter "name=django_videoanalytics"); \
	sudo docker exec -it $$CONTAINER_ID sh
	@echo "$(COLOR_GREEN)$(TAB)Backend container sh successfully!$(COLOR_CLEAR)"

compose-up-script:
	@echo "$(COLOR_YELLOW)$(TAB)Starting Docker Compose...$(COLOR_CLEAR)"
	@sudo docker compose -f $(DOCKER_COMPOSE_BACKEND) up -d
	@echo "$(COLOR_GREEN)$(TAB)Docker Compose up finished successfully!$(COLOR_CLEAR)"

see-backend-logs:
	@echo "$(COLOR_YELLOW)$(TAB)Backend logs...$(COLOR_CLEAR)"
	@export CONTAINER_ID=$$(sudo docker ps -q --filter "name=django_videoanalytics"); \
	sudo docker exec -it $$CONTAINER_ID tail -f /var/log/fastapi.log
	@echo "$(COLOR_GREEN)$(TAB)Backend logs finished successfully!$(COLOR_CLEAR)"

see-backend-deep-logs:
	@echo "$(COLOR_YELLOW)$(TAB)Backend deep logs...$(COLOR_CLEAR)"
	@export CONTAINER_ID=$$(sudo docker ps -q --filter "name=django_videoanalytics"); \
	sudo docker exec -it $$CONTAINER_ID cat /var/log/fastapi.log
	@echo "$(COLOR_GREEN)$(TAB)Backend deep logs finished successfully!$(COLOR_CLEAR)"

stop-containers-without-read:
	@echo "\n\n\n"
	@figlet -c -t -f "ANSI Shadow" Stopping...
	@echo "\n\n\n"
	@echo "$(COLOR_YELLOW)$(TAB)$(TAB)$(TAB)Stopping all containers...$(COLOR_CLEAR)"
	@sudo docker compose -f $(DOCKER_COMPOSE_BACKEND) down
	@echo "$(COLOR_GREEN)$(TAB)Stopping finished successfully!$(COLOR_CLEAR)"

stop-containers:
	@echo "$(COLOR_YELLOW)$(TAB)$(TAB)Do you want to Stop all containers of this project!? If yes - type [yes], if no - type [any button]$(COLOR_CLEAR)"
	@read -p "$(COLOR_YELLOW)$(TAB)$(TAB)Type choices: [yes/any button] $(COLOR_CLEAR)" choice; \
	if [ "$$choice" = "yes" ]; then \
		echo "\n\n\n"; \
		figlet -c -t -f "ANSI Shadow" Stopping...; \
		echo "\n\n\n"; \
		echo "$(COLOR_YELLOW)$(TAB)$(TAB)$(TAB)Stopping all containers...$(COLOR_CLEAR)"; \
		sudo docker compose -f $(DOCKER_COMPOSE_BACKEND) down; \
	else \
		echo "$(COLOR_GREEN)$(TAB)$(TAB)$(TAB)Stopping canceled!$(COLOR_CLEAR)"; \
	fi
	@echo "$(COLOR_GREEN)$(TAB)Stopping finished successfully!$(COLOR_CLEAR)"

fclean: stop
	@-read -p "$(COLOR_RED)$(TAB) WARNING: all containers, images will be deleted! Are you sure? [yes/no] $(COLOR_CLEAR)" choice; \
	if [ "$$choice" = "yes" ]; then \
		echo "\n\n\n"; \
		figlet -c -t -f "ANSI Shadow" Deleting...; \
		echo "\n\n\n"; \
		echo "$(COLOR_YELLOW)$(TAB)$(TAB)$(TAB)Deleting...$(COLOR_CLEAR)"; \
		sudo docker rmi -f $$(sudo docker images -a --quiet); \
	else \
		echo "$(COLOR_GREEN)$(TAB)$(TAB)$(TAB)Cleaning canceled!$(COLOR_CLEAR)"; \
	fi
	@echo "$(COLOR_GREEN)$(TAB)Deleting finished successfully!$(COLOR_CLEAR)"

ffclean:
	@-read -p "$(COLOR_RED)$(TAB) WARNING: all containers, images, volumes, networks, cache will be deleted! Are you sure? [yes/no] $(COLOR_CLEAR)" choice; \
	if [ "$$choice" = "yes" ]; then \
		echo "\n\n\n"; \
		figlet -c -t -f "ANSI Shadow" Deleting...; \
		echo "\n\n\n"; \
		echo "$(COLOR_YELLOW)$(TAB)$(TAB)$(TAB)Deleting...$(COLOR_CLEAR)"; \
		sudo docker rm -f $(docker ps -aq); \
		sudo docker rmi -f $(docker images -aq); \
		sudo docker volume rm $(docker volume ls -q); \
		sudo docker network rm $(docker network ls -q); \
		sudo docker network prune --all --force; \
		sudo docker volume prune --all --force; \
		sudo docker builder prune --all --force; \
	else \
		echo "$(COLOR_GREEN)$(TAB)$(TAB)$(TAB)Cleaning canceled!$(COLOR_CLEAR)"; \
	fi
	@echo "$(COLOR_GREEN)$(TAB)Deleting finished successfully!$(COLOR_CLEAR)"

check:
	@if [ ! "$(shell pwd)" = "$(PROJECT_ROOT)" ]; then \
		echo "Not in project root, please navigate to $(PROJECT_ROOT) before running make"; \
		exit 1; \
	fi
