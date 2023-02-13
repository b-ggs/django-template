.PHONY: build

build:
	docker compose build

start:
	docker compose up -d

stop:
	docker compose down

restart: stop start

sh:
	docker compose exec web bash

test:
	docker compose exec web python3 manage.py test --settings=django_template.settings.test -v=2

test-keepdb:
	docker compose exec web python3 manage.py test --settings=django_template.settings.test -v=2 --keepdb

bump-deps:
	docker compose run --rm --no-deps web poetry up
	npx npm-check-updates -u
	npm install

rename:
	@if [ -z "$$NAME" ]; then \
		echo "Usage:"; \
		echo "    make rename NAME=my_project_name_with_underscores"; \
		echo ""; \
		exit 1; \
	fi
	NAME_KEBAB=$$(echo $$NAME | sed "s/_/-/g")
	echo $$NAME_KEBAB
