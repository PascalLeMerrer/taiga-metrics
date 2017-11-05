##------ General ------

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

run:
run:	## 	 Build and start servers and DB containers
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose build && docker-compose up frontend

logs:
logs:	## 	 Display server logs
	@echo -e "\033[35m > Display server logs \033[0m"
	docker container logs server

clean:
clean:	## 	 Stops all containers, then destroy them
	@echo -e "\033[35m > Stop and destroy containers \033[0m"
	docker-compose kill
	docker container prune --force

##------ DB ------

db: 		## Rebuild and run database
	@echo -e "\033[7;34m > (Re)build and run database  \033[0m"
	docker-compose up --build --force-recreate db

db_shell: 	## Open Postgres console (PSQL)
	@echo -e "\033[7;34m > Open database shell   \033[0m"
	docker exec -it db psql --user taigametrics --password taigametrics

##------ Tests ------

test:
test:	## 	 Run all and test
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose build && docker-compose up

feature:
feature:	## Run feature tests only, assuming the backend is up and running
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose up test

