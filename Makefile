.PHONY: build

build:
	docker compose build

start:
	docker compose up -d

stop:
	docker compose down

sh:
	docker compose exec web bash

test:
	docker compose exec web python3 manage.py test --settings=django_template.settings.test -v=2

test-keepdb:
	docker compose exec web python3 manage.py test --settings=django_template.settings.test -v=2 --keepdb

bump-deps:
	docker compose run --no-deps web poetry up
	npx npm-check-updates -u
	npm install
