from django.apps import apps
from django.contrib import admin
from django.urls import include, path

from django_template.home import urls as home_urls

urlpatterns = [
    path("", include(home_urls)),
    path("django-admin/", admin.site.urls),
]


if apps.is_installed("silk"):
    urlpatterns.append(path("silk/", include("silk.urls")))

if apps.is_installed("django_browser_reload"):
    urlpatterns.append(path("__reload__/", include("django_browser_reload.urls")))
