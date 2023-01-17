# Production build stage
FROM python:3.10 as production

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

# Install poetry
# Make sure poetry version is in sync with CI configs
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
RUN python -m venv $VIRTUAL_ENV
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

# Install main and dev project dependencies
RUN poetry install --no-root

# Add bash aliases
RUN echo "alias dj='./manage.py'" >> $HOME/.bash_aliases
RUN echo "alias djrun='./manage.py runserver 0:8000'" >> $HOME/.bash_aliases

# Add poetry-plugin-up
RUN poetry self add poetry-plugin-up
