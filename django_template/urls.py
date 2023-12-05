from django.contrib import admin
from django.urls import include, path

from django_template.home import urls as home_urls

urlpatterns = [
    path("", include(home_urls)),
    path("django-admin/", admin.site.urls),
]

foo: int =  "foo"
