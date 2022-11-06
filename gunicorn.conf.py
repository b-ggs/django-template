import os

# Log to stdout
# https://docs.gunicorn.org/en/stable/settings.html#accesslog
accesslog = "-"


# Restart worker after this amount of requests
# https://docs.gunicorn.org/en/stable/settings.html#max-requests
max_requests = 1000


# Number of workers
# https://docs.gunicorn.org/en/stable/settings.html#workers


def get_max_workers() -> int:
    # Gunicorn recommends (number of cores * 2~4)
    if count := os.cpu_count():
        return (count * 2) + 1
    return 3


# Check if WEB_CONCURRENCY is available, else use recommended based on CPU count
workers = int(os.getenv("WEB_CONCURRENCY", get_max_workers()))
