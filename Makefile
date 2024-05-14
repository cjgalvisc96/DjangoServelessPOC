## 🧙‍♂️ GLOBALS
.DEFAULT_GOAL := help
SHELL := $(shell which bash)
ROOT_PATH := $(shell pwd)
### ALIAS
ALIAS_MAKE := $(shell which make)
ALIAS_AWSLOCAL := $(shell which aws) --profile localstack
ALIAS_TERRAGRUNT := $(shell which terragrunt)
ALIAS_DOCKER := docker
ALIAS_DOCKER_COMPOSE := docker compose
### DOCKER
DOCKER_FOLDER := ${ROOT_PATH}/docker
DOCKER_COMPOSE_FILE_PATH = ${DOCKER_FOLDER}/docker-compose.loc.yml
### TERRAGRUNT
ENV_NAME ?= # default
TG_ENV_PATH :=  ${ROOT_PATH}/terraform/environments/${ENV_NAME}

.PHONY: help 
help: ## To check the help commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m : %s\n", $$1, $$2}'

## 🌎 CORE
.PHONY: django_serveless_poc_down
django_serveless_poc_down: ## To down the app
	${ALIAS_DOCKER_COMPOSE} -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) down

.PHONY: django_serveless_poc_up
django_serveless_poc_up: django_serveless_poc_down ## To launch the up
	if [ -z "$$(${ALIAS_DOCKER} network ls | grep django_serveless_poc-net)" ]; then \
		${ALIAS_DOCKER} network create --driver bridge django_serveless_poc-net; \
	else \
    	echo "'django_serveless_poc-net' network already exists."; \
	fi
	${ALIAS_DOCKER_COMPOSE} -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) up -d
	sleep 2
	${ALIAS_MAKE} django_serveless_poc_logs

.PHONY: django_serveless_poc_logs 
django_serveless_poc_logs: ## to check the backend logs
	${ALIAS_DOCKER} logs django_serveless_poc_container -f

.PHONY: db_logs 
db_logs: ## to check the DB logs
	${ALIAS_DOCKER} logs db_container  -f

.PHONY: localstack_pro_logs 
localstack_pro_logs: ## to check the Localstack logs
	${ALIAS_DOCKER} logs localstack_container -f

.PHONY: aws_cli_local_logs 
aws_cli_local_logs: ## to check the Localstack logs
	${ALIAS_DOCKER} logs aws_cli_local_container -f

## 🦊 TERRAFORM	
.PHONY: deploy
deploy: ## To deploy the infrastucture in AWS, Ex: deploy ENV_NAME=dev
	${ALIAS_TERRAGRUNT} init --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH}
	${ALIAS_TERRAGRUNT} plan --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH}
	${ALIAS_TERRAGRUNT} apply --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH} -auto-approve

.PHONY: destroy
destroy: ## WARNING: Use this with precaution! To destroy the entery infrastucture deployed in AWS, Ex: destroy ENV_NAME=dev
	${ALIAS_TERRAGRUNT} destroy --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH} -auto-approve

.PHONY: push_docker_image_in_ecs
push_docker_image_in_ecs:
	${ALIAS_DOCKER} build -t django_serveless_poc_ecr_image -f ${DOCKER_FOLDER}/django.Dockerfile .
	${ALIAS_DOCKER} tag django_serveless_poc_ecr_image:latest localhost.localstack.cloud:4510/dev_django_serveless_poc_ecr_repository:latest
	${ALIAS_DOCKER} push localhost.localstack.cloud:4510/dev_django_serveless_poc_ecr_repository:latest
