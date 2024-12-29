from .base import *  # noqa

DJANGO_ENV = "development"

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = "django-insecure-nvg5arlsvczsdk5pzu-=f2qpst%ze8#jyuhfmldp7--j#ao5)j"  # pragma: allowlist secret  # nosec  # noqa: E501

# SECURITY WARNING: define the correct hosts in production!
ALLOWED_HOSTS = ["*"]


# django-browser-reload
# https://github.com/adamchainz/django-browser-reload
INSTALLED_APPS.append("django_browser_reload")  # noqa: F405
MIDDLEWARE.append("django_browser_reload.middleware.BrowserReloadMiddleware")  # noqa: F405


# django-silk
# https://github.com/jazzband/django-silk
INSTALLED_APPS.append("silk")  # noqa: F405
MIDDLEWARE.insert(0, "silk.middleware.SilkyMiddleware")  # noqa: F405


# django-extensions
# https://django-extensions.readthedocs.io/en/stable/

# Configure IPython to automatically reload modules
# https://ipython.org/ipython-doc/3/config/extensions/autoreload.html
IPYTHON_ARGUMENTS = [
    "-c=%load_ext autoreload\n%autoreload 2",
    "-i",
]
