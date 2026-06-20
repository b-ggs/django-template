import os

# Log to stdout
# https://docs.gunicorn.org/en/stable/settings.html#accesslog
accesslog = "-"


# Restart worker after this amount of requests
# https://docs.gunicorn.org/en/stable/settings.html#max-requests
max_requests = 1000


# Number of workers
# https://docs.gunicorn.org/en/stable/settings.html#workers
#
# If GUNICORN_WORKER_COUNT is unset, this falls back to Gunicorn's default
# worker count.
# See the docs for how Gunicorn determines the default worker count.

if worker_count := os.getenv("GUNICORN_WORKER_COUNT"):
    workers = int(worker_count)
