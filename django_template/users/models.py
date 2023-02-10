from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    pass


class TestModel(models.Model):
    test = models.CharField()
