##------ General ------

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

run:
run:	## 	 Build and start all containers
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose build && docker-compose up # --abort-on-container-exit


db: 	## Rebuild and run database
	@echo -e "\033[7;34m > (Re)build and run database  \033[0m"
	docker-compose up --build --force-recreate db

db_shell: 	## Open PSQL
	@echo -e "\033[7;34m > Open database shell   \033[0m"
	docker exec -it taiga-metrics-db psql --user taigametricsdb --password taiga-metrics