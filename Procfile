# Used for defining processes on Heroku or Dokku
# https://devcenter.heroku.com/articles/procfile
# https://dokku.com/docs/deployment/builders/dockerfiles/#procfiles-and-multiple-processes
release: python3 manage.py migrate
web: docker-start gunicorn
celery: docker-start celery
celery-beat: docker-start celery-beat
