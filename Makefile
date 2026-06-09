.PHONY: up down restart status logs validate test distribution clean

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart haproxy

status:
	docker compose ps

logs:
	docker compose logs -f haproxy

validate:
	docker compose run --rm haproxy haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

test:
	curl -s -i localhost:8080

clean:
	docker compose down -v --remove-orphans
