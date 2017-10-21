##------ General ------

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

run:
run:	## 	 Build and start all containers
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose build && docker-compose up