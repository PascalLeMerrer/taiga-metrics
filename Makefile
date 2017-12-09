##------ General ------

help:           ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

install:	## Install dev environment
	npm install

run:	## 	 Build and start servers and DB containers
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose build server db && docker-compose up server

logs:	## 	 Display server logs
	@echo -e "\033[35m > Display server logs \033[0m"
	docker container logs server

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

##----- Client ------

client:		## Compiles the client
	@echo -e "\033[7;34m > Compiles the Elm app to JS  \033[0m"
	elm make client/*.elm --output server/public/js/taigametrics.js --debug

##----- Simulator ------

simulator:	## Simulates Taiga API
	@echo -e "\033[7;34m > Start Taiga API Simulator based on db.json  \033[0m"
	docker-compose up simulator


##------ Tests ------

test:	## 	 Run all and test
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose build && docker-compose up --abort-on-container-exit

feature:	## Run feature tests only, assuming the backend is up and running
	@echo -e "\033[35m > Run all \033[0m"
	docker-compose up test

.PHONY: client simulator