build:
	docker compose build

start:
	docker compose up -d

stop:
	docker compose down

sh:
	docker compose exec web bash
