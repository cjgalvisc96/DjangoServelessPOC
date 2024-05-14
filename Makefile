## 🧙‍♂️ Globals
SHELL := $(shell which bash)
DOCKER_COMPOSE_FILE_PATH = "./docker/docker-compose.loc.yml"
.DEFAULT_GOAL := help
ALIAS_AWSLOCAL := $(shell which aws) --profile localstack

.PHONY: help 
help: ## To check the help commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m : %s\n", $$1, $$2}'

.PHONY: django_serveless_poc_deps
django_serveless_poc_deps: ## To check the Makefile dependencies
ifndef $(shell command -v docker)
	@echo "Docker is not available. Please install docker"
	@exit 1
endif

## 🌎 Core

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
# sleep 2
	make django_serveless_poc_logs

.PHONY: django_serveless_poc_logs 
django_serveless_poc_logs: ## to check the backend logs
	docker logs django_serveless_poc_container -f

.PHONY: db_logs 
db_logs: ## to check the DB logs
	docker logs db_container  -f

.PHONY: localstack_free_logs 
localstack_free_logs: ## to check the Localstack logs
	docker logs localstack_container -f

.PHONY: aws_cli_local_logs 
aws_cli_local_logs: ## to check the Localstack logs
	docker logs aws_cli_local_container -f
