from django.db import connection
from django.http import HttpResponse
from django.views.decorators.http import require_GET


@require_GET
def health(_request):
    with connection.cursor() as cursor:
        cursor.execute("SELECT 1")
    return HttpResponse()
