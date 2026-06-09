.PHONY: up down restart logs validate test status distribution canary rollback clean

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart haproxy

logs:
	docker compose logs -f haproxy

validate:
	docker compose run --rm haproxy haproxy -c -f /usr/local/etc/haproxy/haproxy.cfg

test:
	curl -s -i 127.0.0.1:8080

status:
	./scripts/show-status.sh

REQUESTS ?= 100
distribution:
	./scripts/show-distribution.sh $(REQUESTS)

canary:
	@if [ -z "$(PERCENT)" ]; then \
		echo "Error: PERCENT is missing. Usage: make canary PERCENT=10"; \
		exit 1; \
	fi
	./scripts/set-canary.sh $(PERCENT)

rollback:
	./scripts/rollback.sh

clean:
	docker compose down -v --remove-orphans
