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
	docker compose run --rm --no-deps web poetry up --latest
	npx npm-check-updates -u
	npm install

rename:
	@# Check if PROJECT_NAME is defined
	@if [ -z "$$PROJECT_NAME" ]; then \
		echo ""; \
		echo "Usage:"; \
		echo "    make rename PROJECT_NAME=my_project_name_with_underscores"; \
		echo ""; \
		exit 1; \
	fi

	@# Get a version of PROJECT_NAME but with dashes instead of underscores
	$(eval PROJECT_NAME_KEBAB := $(subst _,-,$(PROJECT_NAME)))

	@echo ""
	@echo "This Makefile target will:"
	@echo "1.) Remove the existing \`.git\` directory"
	@echo "2.) Will replace all instances of the following in files and folders:"
	@echo "  - \`django_template\` with \`$(PROJECT_NAME)\`"
	@echo "  - \`django-template\` with \`$(PROJECT_NAME_KEBAB)\`"
	@echo ""
	@echo "Proceeding in 10 seconds..."
	@echo ""

	@sleep 10

	@# Remove the existing .git directory
	rm -rf .git

	@# Rename the django_template directory
	mv django_template $(PROJECT_NAME)

	@# Replace all instances of django_template with PROJECT_NAME
	grep -rl django_template . | xargs perl -i -pe "s/django_template/$(PROJECT_NAME)/g"

	@# Replace all instances of django-template with PROJECT_NAME_KEBAB
	grep -rl django-template . | xargs perl -i -pe "s/django-template/$(PROJECT_NAME_KEBAB)/g"

	@echo ""
	@echo "Done!"
