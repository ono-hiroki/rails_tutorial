WEB_CONTAINER_ID=web
DB_CONTAINER_ID=db

define DOCKER_COMPOSE_BUILD
docker-compose build
endef

define DOCKER_COMPOSE_UP
docker-compose up
endef

define COMMON
docker-compose run --rm web bundle exec rake db:create db:schema:load data:migrate
endef

define CREATE_FEMAPP_USER
docker-compose run --rm web bundle exec rake femapp_user:create:dev_user
endef

tail-logs:
	docker-compose logs -f web

bash:
	docker exec -it $(WEB_CONTAINER_ID) bash

db-bash:
	docker exec -e LANG=C.UTF-8 -e PGHOST=db -e PGUSER=postgres -e PGPASSWORD=password -it $(DB_CONTAINER_ID) bash

psql:
	docker exec -e LANG=C.UTF-8 -e PGHOST=db -e PGUSER=postgres -e PGPASSWORD=password -it $(DB_CONTAINER_ID) psql

show-dashboard-url:
	docker-compose exec web bundle exec rails clinic_admin:show_dashboard_url

create-admin-user:
	docker-compose exec web bundle exec rake clinic_user:create:admin

jobs:
	docker-compose exec web bundle exec rake jobs:work

create-femapp-user:
	$(CREATE_FEMAPP_USER)

setup:
	$(DOCKER_COMPOSE_BUILD)
	$(COMMON)
	$(DOCKER_COMPOSE_UP)

setup-femapp:
	$(DOCKER_COMPOSE_BUILD)
	$(COMMON)
	$(CREATE_FEMAPP_USER)
	$(DOCKER_COMPOSE_UP)

seed:
	docker-compose exec web rails db:seed
mr:
	docker-compose exec web rake db:migrate:reset
m:
	docker-compose exec web rails db:migrate
b:
	docker-compose exec web bundle install
s:
	$(DOCKER_COMPOSE_UP)
p:
	docker-compose stop
c:
	docker-compose exec web rails c
r:
	docker-compose exec web bundle exec rspec
rr:
	docker-compose exec web bundle exec rake routes
gd:
	docker-compose exec web bundle exec rake graphql:dump_schema
npm-start:
	docker exec -it $(WEB_CONTAINER_ID) bash -c 'cd frontend && npm start'
