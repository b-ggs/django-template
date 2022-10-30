# https://docs.gunicorn.org/en/stable/settings.html

from os import cpu_count

# Log to stdout
# https://docs.gunicorn.org/en/stable/settings.html#accesslog
accesslog = "-"


# Restart worker after this amount of requests
# https://docs.gunicorn.org/en/stable/settings.html#max-requests
max_requests = 1000


# Number of workers
# https://docs.gunicorn.org/en/stable/settings.html#workers
# Gunicorn docs recommend (number of cores * 2~4)


def get_max_workers() -> int:
    if count := cpu_count():
        return (count * 2) + 1
    return 3


workers = get_max_workers()
