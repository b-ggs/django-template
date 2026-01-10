##############################
# Poetry install build stage #
##############################

# Make sure Python version is in sync with CI configs
FROM python:3.14-slim-trixie AS poetry-install

# Install Poetry
# Make sure Poetry version is in sync with CI configs
ENV POETRY_VERSION=2.2.1
ENV POETRY_HOME=/opt/poetry
ENV PATH=/opt/poetry/bin:$PATH
ADD https://install.python-poetry.org /tmp/poetry-install.py
RUN python3 /tmp/poetry-install.py

####################
# Base build stage #
####################

# Make sure Python version is in sync with CI configs
FROM python:3.14-slim-trixie AS base

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

# Set up node_modules so it's owned and writable by the unprivileged user
RUN mkdir -p "$APP_DIR/node_modules" \
  && chown -R django_template:django_template "$APP_DIR/node_modules"

# Set up virtualenv
ENV VIRTUAL_ENV=/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN mkdir -p "$VIRTUAL_ENV" \
  && chown -R django_template:django_template "$VIRTUAL_ENV"

# Install Poetry
# Make sure Poetry version is in sync with CI configs
ENV POETRY_VERSION=2.2.1
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
CMD ["docker-start", "gunicorn"]

##############################
# Pre-production build stage #
##############################

FROM base AS pre-production

# Switch to root to install packages from apt
USER root

# Download NodeSource apt setup script
ADD https://deb.nodesource.com/setup_24.x /tmp/nodesource-setup.sh

# Install Node.js for Node dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  bash /tmp/nodesource-setup.sh \
  # The NodeSource setup script already runs apt-get update
  && apt-get install -y nodejs

# Switch back to unprivileged user
USER django_template

# Copy Poetry from poetry-install
ENV POETRY_HOME=/opt/poetry
ENV PATH=/opt/poetry/bin:$PATH
COPY --from=poetry-install --chown=django_template:django_template /opt/poetry /opt/poetry

# Install main project dependencies
RUN --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
  --mount=type=bind,source=poetry.lock,target=/app/poetry.lock \
  --mount=type=cache,target=/home/django_template/.cache/pypoetry,uid=1000 \
  --mount=type=cache,target=/home/django_template/.cache/pip,uid=1000 \
  poetry install --only main

# Install Node dependencies
RUN --mount=type=bind,source=package.json,target=/app/package.json \
  --mount=type=bind,source=package-lock.json,target=/app/package-lock.json \
  --mount=type=cache,target=/home/django_template/.npm,uid=1000 \
  npm ci

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=django_template:django_template . .

# Build minified Tailwind styles
RUN npm run tailwind:build

# Collect staticfiles
RUN SECRET_KEY=dummy python3 manage.py collectstatic --noinput --clear

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
  && apt-get install -y libpq-dev

# Switch back to unprivileged user
USER django_template

# Copy Poetry from poetry-install
ENV POETRY_HOME=/opt/poetry
ENV PATH=/opt/poetry/bin:$PATH
COPY --from=poetry-install --chown=django_template:django_template /opt/poetry /opt/poetry

# Copy virtualenv from pre-production
COPY --from=pre-production --chown=django_template:django_template /venv /venv

# Copy staticfiles from pre-production
COPY --from=pre-production --chown=django_template:django_template /app/static_collected /app/static_collected

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=django_template:django_template . .

###################
# Dev build stage #
###################

FROM base AS dev

# Temporarily switch to install packages from apt
USER root

# Download Postgres PGP public key
ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc /tmp/postgresql-pgp-public-key.asc

# Download NodeSource apt setup script
ADD https://deb.nodesource.com/setup_24.x /tmp/nodesource-setup.sh

# Install gnupg for installing Postgres client
# Install git for pre-commit
# Install Node.js for Node dependencies
# Install Postgres client for dslr import and export
# Install gettext for i18n
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
  --mount=type=cache,target=/var/lib/apt,sharing=locked \
  apt-get update \
  && apt-get install -y gnupg \
  && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt trixie-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
  && cat /tmp/postgresql-pgp-public-key.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
  && bash /tmp/nodesource-setup.sh \
  # The NodeSource setup script already runs apt-get update
  && apt-get install -y git nodejs postgresql-client-17 gettext

# Switch back to unprivileged user
USER django_template

# Copy Poetry from poetry-install
ENV POETRY_HOME=/opt/poetry
ENV PATH=/opt/poetry/bin:$PATH
COPY --from=poetry-install --chown=django_template:django_template /opt/poetry /opt/poetry

# Install Node dependencies
RUN --mount=type=bind,source=package.json,target=/app/package.json \
  --mount=type=bind,source=package-lock.json,target=/app/package-lock.json \
  --mount=type=cache,target=/home/django_template/.npm,uid=1000 \
  npm ci

# Install all project dependencies
RUN --mount=type=bind,source=pyproject.toml,target=/app/pyproject.toml \
  --mount=type=bind,source=poetry.lock,target=/app/poetry.lock \
  --mount=type=cache,target=/home/django_template/.cache/pypoetry,uid=1000 \
  --mount=type=cache,target=/home/django_template/.cache/pip,uid=1000 \
  poetry install

# Add bash aliases
RUN echo "alias dj='python3 manage.py'" >> $HOME/.bash_aliases
RUN echo "alias djrun='python3 manage.py runserver_plus 0:8000'" >> $HOME/.bash_aliases
RUN echo "alias djtest='python3 manage.py test --settings=django_template.settings.test -v=2'" >> $HOME/.bash_aliases
RUN echo "alias djtestkeepdb='python3 manage.py test --settings=django_template.settings.test -v=2 --keepdb'" >> $HOME/.bash_aliases

# Copy the project files
# Ensure that this is one of the last commands for better layer caching
COPY --chown=django_template:django_template . .
