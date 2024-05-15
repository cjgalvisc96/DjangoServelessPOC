## 🧙‍♂️ GLOBALS
.DEFAULT_GOAL := help
SHELL := $(shell which bash)
ROOT_PATH := $(shell pwd)
### ALIAS
ALIAS_MAKE := $(shell which make)
ALIAS_AWSLOCAL := $(shell which aws) --profile localstack
ALIAS_TERRAGRUNT := $(shell which terragrunt)
# TODO: Get the alias from the shell
ALIAS_DOCKER := docker
ALIAS_DOCKER_COMPOSE := docker compose
### USER VARS
ENV_NAME ?=
DOCKER_IMAGE_NAME ?=
ECR_NAME ?=
### DOCKER
DOCKER_FOLDER := ${ROOT_PATH}/docker
DOCKER_COMPOSE_FILE_PATH = ${DOCKER_FOLDER}/docker-compose.loc.yml
### TERRAGRUNT
ECR_ARN := 000000000000.dkr.ecr.us-east-1.localhost.localstack.cloud:4566
TG_ENV_PATH := ${ROOT_PATH}/terraform/environments/${ENV_NAME}

.PHONY: help 
help: ## To check the help commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m : %s\n", $$1, $$2}'

## 🌎 CORE
.PHONY: django-serveless-poc-down
django-serveless-poc-down: ## To down the app
	${ALIAS_DOCKER_COMPOSE} -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) down

.PHONY: django-serveless-poc-up
django-serveless-poc-up: django-serveless-poc-down ## To launch the up
	if [ -z "$$(${ALIAS_DOCKER} network ls | grep django-serveless-poc-net)" ]; then \
		${ALIAS_DOCKER} network create --driver bridge django-serveless-poc-net; \
	else \
    	echo "'django-serveless-poc-net' network already exists."; \
	fi
	${ALIAS_DOCKER_COMPOSE} -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) up -d

.PHONY: django-serveless-poc-logs 
django-serveless-poc-logs: ## To check the backend logs
	${ALIAS_DOCKER} logs django-serveless-poc-container -f

.PHONY: db-logs 
db-logs: ## To check the DB logs
	${ALIAS_DOCKER} logs db-container  -f

.PHONY: localstack-pro-logs 
localstack-pro-logs: ## To check the Localstack logs
	${ALIAS_DOCKER} logs localstack-container -f

.PHONY: aws-cli-local-logs 
aws-cli-local-logs: ## To check the aws-cli-local logs
	${ALIAS_DOCKER} logs aws-cli-local-container -f

.PHONY: django-serveless-poc-sh
django-serveless-poc-sh:
	${ALIAS_DOCKER_COMPOSE} -p django_serveless_poc -f $(DOCKER_COMPOSE_FILE_PATH) exec django-serveless-poc-backend sh

## 🦊 TERRAFORM	
.PHONY: push-docker-image-in-ecs
push-docker-image-in-ecs: ## To push the docker image in ECR, Ex: push-docker-image-in-ecs DOCKER_IMAGE_NAME=dev-django-serveless-poc-image ECR_NAME=dev-elucid-ecr-repository
	${ALIAS_DOCKER} build -t ${DOCKER_IMAGE_NAME} -f ${DOCKER_FOLDER}/django.Dockerfile .
	${ALIAS_DOCKER} tag ${DOCKER_IMAGE_NAME}:latest ${ECR_ARN}/${ECR_NAME}:latest
	${ALIAS_DOCKER} push ${ECR_ARN}/${ECR_NAME}:latest

.PHONY: apply_terraform_commands
apply_terraform_commands: ## To execute the set of terraform commands(init->plan->apply)
	${ALIAS_TERRAGRUNT} init --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH}
	${ALIAS_TERRAGRUNT} plan --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH}
	${ALIAS_TERRAGRUNT} apply --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH} -auto-approve

.PHONY: deploy
deploy: ## To deploy the infrastucture in AWS, Ex: deploy ENV_NAME=dev
	${ALIAS_MAKE} apply_terraform_commands	
	sleep 1
	${ALIAS_MAKE} push-docker-image-in-ecs DOCKER_IMAGE_NAME=dev-django-serveless-poc-image ECR_NAME=dev-elucid-ecr-repository
	sleep 2
# HACK: For some reason Localstack only effect the var.elucid_lb_target_group.health_check.port = 80, during the second deploy(search this issue)
	${ALIAS_MAKE} apply_terraform_commands	

.PHONY: destroy
destroy: ## WARNING! To destroy all the infrastucture deployed in AWS, Ex: destroy ENV_NAME=dev
	${ALIAS_TERRAGRUNT} destroy --terragrunt-non-interactive --terragrunt-working-dir ${TG_ENV_PATH} -auto-approve

.PHONY: run_poc
run_poc: ## To run the full POC simulating a "DEV" environment
	${ALIAS_MAKE} django-serveless-poc-up
	${ALIAS_MAKE} deploy ENV_NAME=dev
	${ALIAS_AWSLOCAL} elbv2 describe-load-balancers --query "LoadBalancers[*].{Name:LoadBalancerName,DNSName:DNSName}" --output table