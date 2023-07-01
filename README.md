# django-template

A template project with:

- Python 3.11
- Django 4.2
- Postgres 15

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

Click on the **"Use this template"** button on GitHub and create a new repository.

Clone your new repository.

Ensure that you have GNU or BSD Make installed.

Run the `rename` Makefile target to replace all instances of `django_template` and `django-template` with your project's name in snake_case and kebab-case, respectively.

```bash
make rename PROJECT_NAME=my_project_name_with_underscores
```

## Running the project locally

Ensure that you have the following installed:

- GNU or BSD Make
- Docker
- Docker Compose

Copy the included env file example.

```bash
cp .env.example .env
```

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
