include .env

PROJECT_NAME = $(PROJECT_NAME)
SRC_DIR = ./
TEST_DIR = $(SRC_DIR)...
GO = @go
DOC = @docker
MIG = migrate

# GO commands
GO_BUILD = $(GO) build
GO_TEST = $(GO) test
GO_TIDY = $(GO) mod tidy

MG ?= 
MIGRATION_VERSION = $(MG)

# Target

build: 
	$(GO_BUILD) -o bin/$(PROJECT_NAME) -v cmd/main.go

run: build
	bin/$(PROJECT_NAME)
	

test:
	$(GO_TEST) -v $(TEST_DIR)

clean_cached:
	$(GO) clean -testcache

tidy:
	$(GO_TIDY)

create_migrations:
	@for name in $(filter-out $@,$(MAKECMDGOALS)); do \
		echo "Creating migration for: $$name"; \
		$(MIG) create -ext sql -dir cmd/migrate/migrations $$name; \
		sleep 1; \
	done

migration_force:
	$(GO) run cmd/migrate/main.go force $(MIGRATION_VERSION)

migrate_up:
	$(GO) run cmd/migrate/main.go up

migrate_down:
	$(GO) run cmd/migrate/main.go down

migrate_down_one:
	$(GO) run cmd/migrate/main.go down_one

create_container:
	$(DOC) run --name $(POSTGRES_DOCKER_CONTAINER) -e POSTGRES_USER=$(POSTGRES_USER_DOCKER_CONTAINER) -e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD_DOCKER_CONTAINER) -p $(POSTGRES_DB_PORT_HOST_DOCKER_CONTAINER):$(POSTGRES_DB_PORT_DOCKER_CONTAINER) -d postgres:12-alpine

create_db:
	$(DOC) exec -it $(POSTGRES_DOCKER_CONTAINER) psql -U $(POSTGRES_USER_DOCKER_CONTAINER) -c "CREATE DATABASE $(POSTGRES_DB_NAME_DOCKER_CONTAINER)"

start_container:
	$(DOC) start $(POSTGRES_DOCKER_CONTAINER)


# todo: add docker compose up and air under one command to start db container the run air so that i don't have to run the start docker db myself


pop:
	@echo $(word 1, $(filter-out $@,$(MAKECMDGOALS)))

generate_proto::
	go tool buf generate --template buf.gen.yaml