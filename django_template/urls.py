from django.apps import apps
from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from django_template import views
from django_template.auth import urls as auth_urls
from django_template.home import urls as home_urls

api_urlpatterns = [
    path("schema/", SpectacularAPIView.as_view(), name="schema"),
    path(
        "schema/swagger-ui/",
        SpectacularSwaggerView.as_view(url_name="schema"),
        name="swagger-ui",
    ),
    path("auth/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("auth/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("auth/", include(auth_urls.api_urlpatterns)),
]

urlpatterns = [
    path("", include(home_urls)),
    path("api/", include(api_urlpatterns)),
    path("django-admin/", admin.site.urls),
    path("health/", views.health),
]


if apps.is_installed("silk"):
    urlpatterns.append(path("silk/", include("silk.urls")))

if apps.is_installed("django_browser_reload"):
    urlpatterns.append(path("__reload__/", include("django_browser_reload.urls")))
