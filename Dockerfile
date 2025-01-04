####################
# Base build stage #
####################

# Make sure Python version is in sync with CI configs
FROM python:3.12-slim-bookworm AS base

# Configure apt to keep downloaded packages for BuildKit caching
# https://docs.docker.com/reference/dockerfile/#example-cache-apt-packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
  && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

# Set up unprivileged user
RUN useradd --create-home django_template

# Set up project directory
ENV APP_DIR=/app
RUN mkdir -p "$APP_DIR" \
  && chown -R django_template:django_template "$APP_DIR"

# Set up virtualenv
ENV VIRTUAL_ENV=/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN mkdir -p "$VIRTUAL_ENV" \
  && chown -R django_template:django_template "$VIRTUAL_ENV"

# Install Poetry
# Make sure Poetry version is in sync with CI configs
ENV POETRY_VERSION=1.8.5
ENV POETRY_HOME=/opt/poetry
ENV PATH=$POETRY_HOME/bin:$PATH
ADD https://install.python-poetry.org /tmp/poetry-install.py
RUN python3 /tmp/poetry-install.py \
  && chown -R django_template:django_template "$POETRY_HOME"

# Switch to unprivileged user
USER django_template

# Switch to project directory
WORKDIR $APP_DIR

# Set environment variables
# - PYTHONUNBUFFERED: Force Python stdout and stderr streams to be unbuffered
# - PORT: Set port that is used by Gunicorn. This should match the "EXPOSE"
#   command
ENV PYTHONUNBUFFERED=1
ENV PORT=8000

# Install main project dependencies
COPY --chown=django_template:django_template pyproject.toml poetry.lock ./
RUN --mount=type=cache,target=/home/django_template/.cache/pypoetry,uid=1000 \
  python3 -m venv $VIRTUAL_ENV \
  && poetry install --only main

# Port used by this container to serve HTTP
EXPOSE 8000

# Serve project with gunicorn
CMD ["gunicorn", "django_template.wsgi:application"]

##########################
# Production build stage #
##########################

FROM base AS production

# Temporarily switch to install packages from apt
USER root

# Install libpq-dev for psycopg
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get -y install libpq-dev

# Switch back to unprivileged user
USER django_template

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=django_template:django_template . .

# Collect static files
RUN SECRET_KEY=dummy python3 manage.py collectstatic --noinput --clear

###################
# Dev build stage #
###################

FROM base AS dev

# Temporarily switch to install packages from apt
USER root

# Download Postgres PGP public key
ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /tmp/postgresql-pgp-public-key.asc

# Install gnupg for installing Postgres client
# Install Postgres client for dslr import and export
# Install gettext for i18n
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get -y install gnupg \
  && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
  && cat /tmp/postgresql-pgp-public-key.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
  && apt-get update \
  && apt-get -y install postgresql-client-16 gettext

# Switch back to unprivileged user
USER django_template

# Install all project dependencies
RUN --mount=type=cache,target=/home/django_template/.cache/pypoetry,uid=1000 \
  poetry install

# Add bash aliases
RUN echo "alias dj='python3 manage.py'" >> $HOME/.bash_aliases
RUN echo "alias djrun='python3 manage.py runserver_plus 0:8000'" >> $HOME/.bash_aliases
RUN echo "alias djtest='python3 manage.py test --settings=django_template.settings.test -v=2'" >> $HOME/.bash_aliases
RUN echo "alias djtestkeepdb='python3 manage.py test --settings=django_template.settings.test -v=2 --keepdb'" >> $HOME/.bash_aliases

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=django_template:django_template . .
