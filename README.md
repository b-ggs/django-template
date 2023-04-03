# django-template

A template project with:

- Python 3.11
- Django 4.2
- Postgres 14

## Features

- Development inside Docker
- Django settings such as `SECRET_KEY` and `ALLOWED_HOSTS` are configured with environment variables out of the box
- Can be easily deployed to [Heroku][heroku] or [Dokku][dokku]
- Static files are served with [Whitenoise][whitenoise]
- Errors can be sent to [Sentry][sentry] or [GlitchTip][glitchtip]

[heroku]: https://heroku.com
[dokku]: https://dokku.com/
[whitenoise]: http://whitenoise.evans.io/en/stable/
[sentry]: https://sentry.io/
[glitchtip]: https://glitchtip.com/

## Making it your own

Clone this project locally.

Replace all instances of `django_template` and `django-template` with your project's name in snake_case and kebab-case, respectively.

```bash
# Replace these variables with your project's name
export PROJECT_NAME_CAMEL_CASE=my_project_name
export PROJECT_NAME_KEBAB_CASE=my-project-name

# Replace the top-level app name with `$PROJECT_NAME_CAMEL_CASE`
mv django_template "$PROJECT_NAME_CAMEL_CASE"

# Replace all instances of `django_template` with `$PROJECT_NAME_CAMEL_CASE`
grep -rl django_template . | xargs sed -i "s/django_template/$PROJECT_NAME_CAMEL_CASE/g"

# Replace all instances of `django-template` with `$PROJECT_NAME_KEBAB_CASE`
grep -rl django-template . | xargs sed -i "s/django-template/$PROJECT_NAME_KEBAB_CASE/g"
```

Remove the `.git` directory and replace with your project's git configuration.

## Running the project locally

Ensure that you have the following installed:

- GNU or BSD Make
- Docker
- Docker Compose

Build your development environment.

```bash
make build
```

Run your development environment.

```bash
make start
```

Open an interactive shell into the Docker container that contains the Django project.

```bash
make sh
```

Several bash aliases exist in the Django Docker container such as:

- `dj`: `./manage.py`
- `djrun`: `./manage.py runserver 0:8000`
- `djtest`: `./manage.py test --settings=django_template.settings.test -v=2`
- `djtestkeepdb`: `./manage.py test --settings=django_template.settings.test -v=2 --keepdb`

Run all outstanding migrations.

```bash
# Inside the Django Docker container
dj migrate
```

Spin up the development server.

```bash
# Inside the Django Docker container
djrun
```

The Django app will be available at http://localhost:8000/.

Check out the [Makefile](Makefile) for other useful commands.

## Deploying to a managed or self-hosted service

- [Deploying to Dokku](docs/deploying_to_dokku.md)
