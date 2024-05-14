## 🧙‍♂️ GLOBALS
SHELL := $(shell which bash)
ROOT_PATH := $(shell pwd)
DOCKER_COMPOSE_FILE_PATH = "./docker/docker-compose.loc.yml"
.DEFAULT_GOAL := help
ALIAS_AWSLOCAL := $(shell which aws) --profile localstack
ENV_NAME ?= # default
TG_ENV_PATH :=  ${ROOT_PATH}/terraform/environments/${ENV_NAME}

.PHONY: help 
help: ## To check the help commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m : %s\n", $$1, $$2}'

.PHONY: django_serveless_poc_deps
django_serveless_poc_deps: ## To check the Makefile dependencies
ifndef $(shell command -v docker)
	@echo "Docker is not available. Please install docker"
	@exit 1
endif

## 🌎 CORE
.PHONY: django_serveless_poc_down
django_serveless_poc_down: ## To down the app
	docker compose -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) down

.PHONY: django_serveless_poc_up
django_serveless_poc_up: django_serveless_poc_down ## To launch the up
	if [ -z "$$(docker network ls | grep django_serveless_poc-net)" ]; then \
		docker network create --driver bridge django_serveless_poc-net; \
	else \
    	echo "'django_serveless_poc-net' network already exists."; \
	fi
	docker compose -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) up -d
	sleep 2
	make django_serveless_poc_logs

.PHONY: django_serveless_poc_logs 
django_serveless_poc_logs: ## to check the backend logs
	docker logs django_serveless_poc_container -f

.PHONY: db_logs 
db_logs: ## to check the DB logs
	docker logs db_container  -f

.PHONY: localstack_pro_logs 
localstack_pro_logs: ## to check the Localstack logs
	docker logs localstack_container -f

.PHONY: aws_cli_local_logs 
aws_cli_local_logs: ## to check the Localstack logs
	docker logs aws_cli_local_container -f

## 🦊 TERRAFORM	
.PHONY: deploy
deploy: ## To deploy the infrastucture in AWS, Ex: deploy ENV_NAME=dev
	terragrunt init --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH}
	terragrunt plan --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH}
	terragrunt apply --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH} -auto-approve

.PHONY: destroy
destroy: ## WARNING: Use this with precaution! To destroy the entery infrastucture deployed in AWS, Ex: destroy ENV_NAME=dev
	terragrunt destroy --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH} -auto-approve
