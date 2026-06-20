import os
from datetime import timedelta
from pathlib import Path

import dj_database_url
from celery.schedules import crontab
from django.utils.translation import gettext_lazy as _

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

DJANGO_ENV = os.getenv("DJANGO_ENV", "production")

SECRET_KEY = os.getenv("SECRET_KEY", "")

ALLOWED_HOSTS = []
if allowed_hosts := os.getenv("ALLOWED_HOSTS"):
    ALLOWED_HOSTS = allowed_hosts.split(",")

CSRF_TRUSTED_ORIGINS = []
if csrf_trusted_origins := os.getenv("CSRF_TRUSTED_ORIGINS"):
    CSRF_TRUSTED_ORIGINS = csrf_trusted_origins.split(",")


# Application definition

INSTALLED_APPS = [
    # Project apps
    "django_template.auth",
    "django_template.home",
    "django_template.utils",
    "django_template.users",
    # Django core apps
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # Third-party apps
    "django_extensions",
    "rest_framework",
    "rest_framework_simplejwt",
    "rest_framework_simplejwt.token_blacklist",
    "drf_spectacular",
    "drf_standardized_errors",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "django.middleware.locale.LocaleMiddleware",
    # Simplified static file serving
    # https://devcenter.heroku.com/articles/django-assets
    # https://warehouse.python.org/project/whitenoise/
    "whitenoise.middleware.WhiteNoiseMiddleware",
]

ROOT_URLCONF = "django_template.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [os.path.join(BASE_DIR, "templates")],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "django_template.wsgi.application"


# Database
# https://docs.djangoproject.com/en/5.2/ref/settings/#databases

if "DATABASE_URL" in os.environ:
    DATABASES = {
        "default": dj_database_url.parse(
            os.environ["DATABASE_URL"],
            conn_max_age=600,
            conn_health_checks=True,
        ),
    }


# Cache
# https://docs.djangoproject.com/en/5.2/topics/cache/
# https://docs.djangoproject.com/en/5.2/topics/cache/#redis

if redis_url := os.getenv("REDIS_URL"):
    # Heroku Key-Value Store uses self-signed certificates
    # https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-python
    if os.getenv("REDIS_URL_SSL_CERT_REQS_NONE"):
        redis_url += "?ssl_cert_reqs=none"

    CACHES = {
        "default": {
            "BACKEND": "django.core.cache.backends.redis.RedisCache",
            "LOCATION": redis_url,
        }
    }


# Email
# https://docs.djangoproject.com/en/5.2/topics/email/

EMAIL_HOST = os.getenv("EMAIL_HOST", "localhost")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", "25"))
EMAIL_HOST_USER = os.getenv("EMAIL_HOST_USER", "")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_HOST_PASSWORD", "")
EMAIL_USE_TLS = os.getenv("EMAIL_USE_TLS", "false").lower() == "true"
EMAIL_USE_SSL = os.getenv("EMAIL_USE_SSL", "false").lower() == "true"
DEFAULT_FROM_EMAIL = os.getenv("DEFAULT_FROM_EMAIL", "django_template@localhost")


# Internationalization and localization
# https://docs.djangoproject.com/en/5.2/topics/i18n/
# https://docs.djangoproject.com/en/5.2/ref/settings/#std-setting-LANGUAGE_CODE
# https://docs.djangoproject.com/en/5.2/ref/settings/#languages
# https://docs.djangoproject.com/en/5.2/ref/settings/#locale-paths

LANGUAGE_CODE = "en"

LANGUAGES = [
    ("en", _("English")),
    ("tl", _("Tagalog")),
]

LOCALE_PATHS = [os.path.join(BASE_DIR, "locale")]


# Use a custom User model
# https://docs.djangoproject.com/en/5.2/topics/auth/customizing/#substituting-a-custom-user-model

AUTH_USER_MODEL = "users.User"


# Password validation
# https://docs.djangoproject.com/en/5.2/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": (
            "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"
        ),
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]


# Internationalization
# https://docs.djangoproject.com/en/5.2/topics/i18n/

LANGUAGE_CODE = "en-us"

TIME_ZONE = "UTC"

USE_I18N = True

USE_L10N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/5.2/howto/static-files/

STATICFILES_DIRS = [
    # Static files such as images and other assets can be stored in
    # `django_template/static`
    os.path.join(BASE_DIR, "django_template", "static"),
    # Static files that are built by external tooling, e.g. Tailwind
    # are stored in `django_template/static_built`
    os.path.join(BASE_DIR, "django_template", "static_built"),
]

# Collected static files will be stored in static_collected
STATIC_ROOT = os.path.join(BASE_DIR, "static_collected")

STATIC_URL = "/static/"

# README.md files in static folders will be ignored
STATICFILES_FINDERS_IGNORE = [
    "README.md",
]


# Simplified static file serving
# https://devcenter.heroku.com/articles/django-assets
# https://warehouse.python.org/project/whitenoise/

STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}

# Default primary key field type
# https://docs.djangoproject.com/en/5.2/ref/settings/#default-auto-field

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# Logging
# https://docs.djangoproject.com/en/5.2/topics/logging/#configuring-logging

# Log everything from INFO above to stdout
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "[{asctime}][{process:d}][{levelname}][{name}] {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "level": "INFO",
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
    },
    "root": {
        "handlers": ["console"],
        "level": "INFO",
    },
}


# Django REST framework
# https://www.django-rest-framework.org/

REST_FRAMEWORK = {
    "EXCEPTION_HANDLER": "drf_standardized_errors.handler.exception_handler",
    "DEFAULT_AUTHENTICATION_CLASSES": [
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ],
    "DEFAULT_PERMISSION_CLASSES": [
        "rest_framework.permissions.IsAuthenticated",
    ],
    "DEFAULT_PARSER_CLASSES": [
        "rest_framework.parsers.JSONParser",
    ],
    "DEFAULT_THROTTLE_CLASSES": [
        "rest_framework.throttling.AnonRateThrottle",
    ],
    "DEFAULT_THROTTLE_RATES": {
        "anon": "60/min",
    },
    "DEFAULT_SCHEMA_CLASS": "drf_standardized_errors.openapi.AutoSchema",
}


# Django REST framework Simple JWT
# https://django-rest-framework-simplejwt.readthedocs.io/en/stable/

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=30),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
}


# drf-spectacular
# https://drf-spectacular.readthedocs.io/en/latest/

SPECTACULAR_SETTINGS = {
    "TITLE": "django_template",
    "DESCRIPTION": "API documentation for the django_template project",
    "VERSION": "0.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    "SERVE_AUTHENTICATION": [
        "rest_framework.authentication.SessionAuthentication",
    ],
    "SERVE_PERMISSIONS": [
        "rest_framework.permissions.IsAdminUser",
    ],
    "SORT_OPERATIONS": False,
    "ENUM_NAME_OVERRIDES": {
        "ValidationErrorEnum": (
            "drf_standardized_errors.openapi_serializers.ValidationErrorEnum.choices"
        ),
        "ClientErrorEnum": (
            "drf_standardized_errors.openapi_serializers.ClientErrorEnum.choices"
        ),
        "ServerErrorEnum": (
            "drf_standardized_errors.openapi_serializers.ServerErrorEnum.choices"
        ),
        "ErrorCode401Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode401Enum.choices"
        ),
        "ErrorCode403Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode403Enum.choices"
        ),
        "ErrorCode404Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode404Enum.choices"
        ),
        "ErrorCode405Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode405Enum.choices"
        ),
        "ErrorCode406Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode406Enum.choices"
        ),
        "ErrorCode415Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode415Enum.choices"
        ),
        "ErrorCode429Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode429Enum.choices"
        ),
        "ErrorCode500Enum": (
            "drf_standardized_errors.openapi_serializers.ErrorCode500Enum.choices"
        ),
    },
    "POSTPROCESSING_HOOKS": [
        "drf_standardized_errors.openapi_hooks.postprocess_schema_enums",
    ],
}


# drf-standardized-errors
# https://drf-standardized-errors.readthedocs.io/en/stable/

DRF_STANDARDIZED_ERRORS = {
    "ALLOWED_ERROR_STATUS_CODES": ["400", "401", "403", "404", "429", "500"],
}


# Celery and Celery Beat
# https://docs.celeryq.dev/en/stable/index.html
# https://docs.celeryq.dev/en/stable/userguide/periodic-tasks.html

if redis_url := os.getenv("REDIS_URL"):
    # Heroku Key-Value Store uses self-signed certificates
    # https://devcenter.heroku.com/articles/connecting-heroku-redis#connecting-in-python
    if os.getenv("REDIS_URL_SSL_CERT_REQS_NONE"):
        redis_url += "?ssl_cert_reqs=none"

    CELERY_BROKER_URL = redis_url

CELERY_BEAT_SCHEDULE = {
    "hello_world_every_10_minutes": {
        "task": "django_template.home.tasks.hello_world",
        "schedule": 60 * 10,
    },
    "hello_world_every_00": {
        "task": "django_template.home.tasks.hello_world",
        "schedule": crontab(minute="0", hour="*"),
    },
}

CELERY_BROKER_CONNECTION_RETRY_ON_STARTUP = True


# django-extensions
# https://django-extensions.readthedocs.io/en/stable/

# Force runserver_plus to use the stat reloader because watchdog in Docker
# constantly detects changes to template files on macOS hosts
RUNSERVERPLUS_POLLER_RELOADER_TYPE = "stat"

# Use IPython as the shell for shell_plus
SHELL_PLUS = "ipython"


# Error reporting
# https://docs.sentry.io/platforms/python/guides/django/
# https://glitchtip.com/sdkdocs/python-django

if sentry_dsn := os.getenv("SENTRY_DSN"):
    import sentry_sdk
    from sentry_sdk.integrations.django import DjangoIntegration
    from sentry_sdk.utils import get_default_release

    SENTRY_ENVIRONMENT = DJANGO_ENV

    # Attempt to get release version from Sentry's utils and a couple other
    # environment variables
    def get_release_version():
        release = get_default_release()
        # Use GIT_REV for Dokku
        release = release or os.getenv("GIT_REV")
        # Use DJANGO_ENV as a final fallback
        return release or DJANGO_ENV

    sentry_init_args = {
        "dsn": sentry_dsn,
        "integrations": [DjangoIntegration()],
        "environment": SENTRY_ENVIRONMENT,
        "release": get_release_version(),
        "traces_sample_rate": 0.01,
    }

    # Auto session tracking is not supported by GlitchTip
    sentry_init_args["auto_session_tracking"] = "sentry.io" in sentry_dsn

    sentry_sdk.init(**sentry_init_args)
