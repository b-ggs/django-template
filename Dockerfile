FROM python:3.10

# Set up user
RUN useradd --create-home django3_template

# Set up project directory
ENV APP_DIR=/app
RUN mkdir -p "$APP_DIR" && chown -R django3_template "$APP_DIR"

# Set up virtualenv
ENV VIRTUAL_ENV=/venv
ENV PATH=$VIRTUAL_ENV/bin:$PATH
RUN mkdir -p "$VIRTUAL_ENV" && chown -R django3_template:django3_template "$VIRTUAL_ENV"

# Install poetry
ENV POETRY_VERSION=1.2.2
ENV POETRY_HOME=/opt/poetry
ENV PATH=$POETRY_HOME/bin:$PATH
RUN curl -sSL https://install.python-poetry.org | python3 - \
    && chown -R django3_template:django3_template "$POETRY_HOME"

# Switch to unprivileged user
USER django3_template

# Switch to project directory
WORKDIR $APP_DIR

# Set environment variables
# 1. Force Python stdout and stderr streams to be unbuffered.
# 2. Set PORT variable that is used by Gunicorn. This should match "EXPOSE"
#    command.
ENV PYTHONUNBUFFERED=1 \
    PORT=8000

# Install project dependencies
RUN python -m venv $VIRTUAL_ENV
COPY --chown=django3_template pyproject.toml poetry.lock ./
RUN pip install --upgrade pip && poetry install --no-root

# Port used by this container to serve HTTP.
EXPOSE 8000

# Copy the source code of the project into the container.
COPY --chown=django3_template:django3_template . .

# Collect static files.
RUN SECRET_KEY=dummy python3 manage.py collectstatic --noinput --clear

CMD ["gunicorn", "django3_template.wsgi:application"]
