import platform

from django import get_version
from django.views.generic import TemplateView


class IndexView(TemplateView):
    template_name = "home/index.html"

    def get_context_data(self, **kwargs: dict) -> dict:
        context = super().get_context_data(**kwargs)
        context |= {
            "python_version": ".".join(platform.python_version_tuple()),
            "django_version": get_version(),
        }
        return context
