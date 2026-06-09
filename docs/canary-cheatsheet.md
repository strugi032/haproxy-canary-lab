# HAProxy Canary Cheat Sheet

## Request flow

Client -> HAProxy frontend -> application backend -> selected Nginx node

## Why weighted round-robin

Weighted round-robin is highly suitable for small, stateless canary examples because it smoothly distributes incoming requests among active servers in proportion to their weights. It avoids the complexity of stick-tables or cookie-based persistence while ensuring that a mathematically precise portion of traffic reaches the canary node over a large number of requests.

## Health checks

- `/healthz`: A simple endpoint returning HTTP 200 used to determine if the application is healthy.
- `inter`: The interval between two consecutive health checks.
- `fall`: The number of consecutive failed checks before a server is marked as DOWN.
- `rise`: The number of consecutive successful checks before a server is marked as UP.
- `slowstart`: The time over which a newly UP server will gradually receive its full share of traffic, protecting it from sudden traffic bursts.

## Canary rollout

Example progression:

0% -> 5% -> 10% -> 25% -> 50% -> 100%

Traffic percentages are approximate. Because HAProxy distributes connections individually (and clients may close/open connections irregularly), a small sample of requests may not perfectly match the configured weight percentages. Over thousands of requests, it converges to the target.

## Runtime API

Traffic weights can be changed dynamically without restarting HAProxy by issuing commands to its Runtime API socket. 
This means zero dropped packets and no process reload overhead.

**Important:** Runtime API changes are temporary. They are completely lost after an HAProxy restart or reload unless they are persisted separately (e.g., via the Dataplane API, configuration management tooling, or `state-file`).

## Rollback

Rollback simply means setting the canary weight to zero and immediately restoring full traffic weights to the stable nodes. With the Runtime API, this is instantaneous.

## Useful commands

```bash
make validate                       # Validates the HAProxy config
make up                             # Starts the Docker Compose stack
make status                         # Shows current backend status and weights
make distribution REQUESTS=200      # Shows traffic distribution over 200 requests
make canary PERCENT=25              # Sets the canary node to receive 25% of traffic
make rollback                       # Instantly restores 100% traffic to stable nodes
make down                           # Tears down the lab
```

## Interview notes

- **Why use HAProxy for canary traffic?** It is lightweight, extremely fast, deeply configurable, and supports dynamic weight changes via its Runtime API without reloading the process.
- **Why are weights not exact percentages?** HAProxy uses weights relative to the total sum of active backend weights. Furthermore, for a small number of requests, the round-robin distribution algorithm provides an approximation. It requires large volumes of traffic to see exact mathematical alignment.
- **What happens when the canary health check fails?** The `fall` threshold is reached, HAProxy marks the canary DOWN, and 100% of the traffic is instantly redistributed to the remaining healthy nodes in the backend (the stable nodes).
- **What is the difference between config reload and Runtime API change?** A config reload requires restarting the HAProxy process (or launching a new one that takes over the socket), which can momentarily delay connections and requires parsing the entire config file. The Runtime API alters the memory state of the running process instantly and transparently.
- **Why should the application be stateless for this example?** Because we use strict round-robin without sticky sessions. A stateful application would require ensuring a user's session always hits the same node, which breaks the simple percentage-based distribution mechanism demonstrated here.
