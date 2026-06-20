from rest_framework.generics import GenericAPIView
from rest_framework.response import Response

from django_template.users.serializers import UserSerializer


class MeAPIView(GenericAPIView):
    """
    Get details about the current user.
    """

    serializer_class = UserSerializer

    def get(self, request, **kwargs) -> Response:
        serializer = self.get_serializer(request.user)
        return Response(serializer.data)
