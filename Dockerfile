# Production build stage
# Make sure Python version is in sync with CI configs
FROM python:3.11-bullseye as production

# Set up user
RUN useradd --create-home django_template

# Set up project directory
ENV APP_DIR=/app
RUN mkdir -p "$APP_DIR" \
  && chown -R django_template "$APP_DIR"

# Set up virtualenv
ENV VIRTUAL_ENV=/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN mkdir -p "$VIRTUAL_ENV" \
  && chown -R django_template:django_template "$VIRTUAL_ENV"

# Install Poetry
# Make sure Poetry version is in sync with CI configs
ENV POETRY_VERSION=1.3.2
ENV POETRY_HOME=/opt/poetry
ENV PATH=$POETRY_HOME/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && chown -R django_template:django_template "$POETRY_HOME"

# Switch to unprivileged user
USER django_template

# Switch to project directory
WORKDIR $APP_DIR

# Set environment variables
# 1. Force Python stdout and stderr streams to be unbuffered.
# 2. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
#    command.
ENV PYTHONUNBUFFERED=1 \
    PORT=8000

# Install main project dependencies
RUN python3 -m venv $VIRTUAL_ENV
COPY --chown=django_template pyproject.toml poetry.lock ./
RUN pip install --upgrade pip \
  && poetry install --no-root --only main

# Port used by this container to serve HTTP.
EXPOSE 8000

# Copy the source code of the project into the container.
COPY --chown=django_template:django_template . .

# Collect static files.
RUN SECRET_KEY=dummy python3 manage.py collectstatic --noinput --clear

CMD ["gunicorn", "django_template.wsgi:application"]

# Dev build stage
FROM production AS dev

# Temporarily switch to install packages from apt
USER root

# Install Postgres client for dslr import and export
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
  && curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null \
  && apt-get update \
  && apt-get -y install postgresql-client-14 \
  && rm -rf /var/lib/apt/lists/*

# Switch back to unprivileged user
USER django_template

# Install main and dev project dependencies
RUN poetry install --no-root

# Add poetry-plugin-up
RUN poetry self add poetry-plugin-up

# Add bash aliases
RUN echo "alias dj='./manage.py'" >> $HOME/.bash_aliases
RUN echo "alias djrun='./manage.py runserver 0:8000'" >> $HOME/.bash_aliases
RUN echo "alias djtest='./manage.py test --settings=django_template.settings.test -v=2'" >> $HOME/.bash_aliases
RUN echo "alias djtestkeepdb='./manage.py test --settings=django_template.settings.test -v=2 --keepdb'" >> $HOME/.bash_aliases
