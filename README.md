# HAProxy Canary Lab

A practical project demonstrating how HAProxy operates as a load balancer and handles canary deployments via the Runtime API.

## What this lab demonstrates
* HAProxy HTTP traffic distribution.
* Weighted round-robin balancing between stable (`v1`) and canary (`v2`) nodes.
* Active HTTP health checks to automatically remove unhealthy nodes.
* Dynamically changing canary traffic weights without restarting HAProxy.
* Immediate rollback to stable nodes.

## Architecture
- HAProxy Frontend: `:8080`
- HAProxy Stats Page: `:8404`
- HAProxy Runtime API: `127.0.0.1:9999`
- Backends:
  - `web-v1-a` (Stable)
  - `web-v1-b` (Stable)
  - `web-v2-canary` (Canary)

## Usage Commands

**Start the lab:**
```bash
make up
```

**Validate HAProxy configuration:**
```bash
make validate
```

**Test a single request:**
```bash
make test
```

**Check traffic distribution (default 100 requests):**
```bash
make distribution
# Or specify request count:
make distribution REQUESTS=200
```

**Set canary percentage (e.g. 25%):**
```bash
make canary PERCENT=25
```

**Rollback to 100% stable:**
```bash
make rollback
```

**View current backend status (weights & health):**
```bash
make status
```

**Access the Statistics page:**
Open [http://localhost:8404](http://localhost:8404) in your browser.

**Stop the lab:**
```bash
make down
```

Example flow:
```bash
make up
make validate
make distribution
make canary PERCENT=25
make distribution
make rollback
make distribution
make down
```
