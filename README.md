# django-template

A template project with:

- Python 3.10
- Django 4.1

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

TODO: One-liner to replace all instances of `django{_,-}template`.

Remove the `.git` directory and replace with your project's git configuration.

## Developing locally

Ensure that you have the following installed:

- GNU or BSD Make
- Docker
- Docker Compose
- Python 3.10
- Node 18

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

- `dj` = `./manage.py`
- `djrun` = `./manage.py runserver 0:8000`

Run all outstanding migrations.

```bash
# Inside the Docker container
dj migrate
```

Spin up the development server.

```bash
# Inside the Docker container
djrun
```

Your Django app will be available at http://localhost:8000/.

## Deployment

- [Deploying to Dokku](docs/deploying_to_dokku.md)
