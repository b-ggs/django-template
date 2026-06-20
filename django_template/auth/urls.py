from django.urls import path

from . import views

api_urlpatterns = [
    path("me/", views.MeAPIView.as_view(), name="me"),
]
