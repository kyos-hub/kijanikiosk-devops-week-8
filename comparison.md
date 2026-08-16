# Comparing Two Ways to Deploy kk-payments Safely

> ⚠️ Before submitting: replace [SELF_HEALING_TIME] with the value from `self-healing-rerun.txt` and [IMAGE_SIZE_REDUCTION] with the measured reduction from `build-verification.txt` vs. a single-stage baseline build. Both numbers must be real measurements, not estimates.

We set out to answer a simple question: when something goes wrong with our payments service, how quickly can we recover, and how much of that recovery can happen without a person watching a screen? We tested two approaches side by side, and both worked — but they protect us in different ways.

The first approach keeps two full copies of the service running at once. Only one copy takes real customer traffic at a time. When we release a new version, we quietly start it up alongside the old one, then switch traffic over. If something goes wrong, a monitoring process watches the new version continuously and switches traffic straight back the moment it detects trouble — no one has to notice the problem and react by hand.

The second approach packages the service into a lightweight, self-contained unit that can be started, stopped, and replaced automatically by an orchestration system. Instead of keeping two full environments running, this system keeps multiple identical copies of the service alive at once, and if any one of them fails or is removed, a replacement is started automatically within moments — again, with no person needed to intervene.

Both approaches share the same underlying idea: don't wait for a human to catch a problem. But they catch different kinds of problems. The first approach is built to catch a *bad release* — a new version that looks fine on the surface but breaks something. The second approach is built to catch *infrastructure failure* — a crash, a server dying, a process getting killed unexpectedly — and heal from it automatically.

| Concern | Blue/Green Approach | Container Approach |
|---|---|---|
| Deployment mechanism | Two full environments run side by side; traffic is switched between them all at once | One packaged, versioned unit is deployed; multiple identical copies run behind a shared entry point |
| Rollback mechanism | Traffic is switched back to the previous environment when a problem is detected | A failing copy is replaced with a fresh one from the same known-good package; the whole fleet is never "switched" as one unit |
| Failure recovery | Requires a full second environment on standby at all times | Any individual copy can fail and be replaced without affecting the others |
| Scaling | Scaling means running a second full environment — expensive and manual | Scaling means adding more identical copies, which the orchestration system can do automatically based on demand |

In our testing, a deleted service copy was automatically replaced and back to serving traffic in [SELF_HEALING_TIME] — with no manual restart. Separately, packaging the application efficiently — stripping out build tools and unnecessary files — cut the image size by [IMAGE_SIZE_REDUCTION] compared to a naive, single-stage build. Smaller packages start faster and move through our systems more quickly.

What the container approach does not yet solve is *coordinated* recovery across many copies at once, and it does not yet manage configuration or secrets cleanly — right now, some values that should be adjustable per environment are still fixed inside the deployment files themselves. The next phase of this work introduces proper orchestration controls that let the system make smarter decisions about when a copy is truly ready to take traffic, and gives us a safer way to manage sensitive configuration without hardcoding it. Together, the two approaches give us layered protection: one guards against bad releases, the other guards against infrastructure failure, and the next phase closes the remaining gaps between them.
