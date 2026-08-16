# kk-payments — Service Level Indicators & Objectives

## SLIs

### 1. Availability
- **Measured as:** proportion of health-check requests to `/health` that return HTTP 200, sampled from nginx access logs on the active upstream.
- **Calculation:** `successful_health_checks / total_health_checks` over the measurement window.
- **Measurement window:** 30 days, evaluated on a 5-minute rolling basis for alerting.

### 2. Latency (p95 response time)
- **Measured as:** 95th percentile response time for payment requests, read from nginx `$request_time` in the access log.
- **Calculation:** p95 of `$request_time` across all `/api/payments/*` requests in the window.
- **Measurement window:** 30 days, evaluated on a 5-minute rolling basis for alerting.

### 3. Payment error rate
- **Measured as:** proportion of payment requests returning a 5xx status or an application-level payment-failure code, read from application logs (hypothetical structured log with a `status` field, since kk-payments does not yet emit metrics to a dedicated system).
- **Calculation:** `failed_payment_requests / total_payment_requests` over the measurement window.
- **Measurement window:** 30 days, evaluated on a 5-minute rolling basis for alerting.

## SLO Targets (30-day window)

| SLI | SLO Target | Status |
|---|---|---|
| Availability | ≥ 99.9% | Proposed target (not yet measured against production traffic) |
| Latency (p95) | ≤ 400ms | Proposed target (not yet measured against production traffic) |
| Payment error rate | ≤ 0.1% | Proposed target (not yet measured against production traffic) |

## Rollback Threshold Table

| SLI | Short-window rollback threshold | Relationship to SLO |
|---|---|---|
| Availability | < 95% over a 60-second window (3 consecutive failed health checks at 5s poll interval) | Deliberately far below the 99.9% 30-day target — a short window needs a much looser bound so a single blip doesn't trigger unnecessary rollback, while a sustained failure still fires fast |
| Latency (p95) | > 1200ms sustained over 60 seconds | 3x the 400ms target — short-window noise is higher than the 30-day aggregate, so the trigger threshold is set with headroom to avoid false positives |
| Payment error rate | > 5% over a 60-second window | 50x the 0.1% target — a short window has low sample size, so the threshold has to be loose enough to avoid tripping on 1-2 unlucky requests while still catching a real outage |

## What We Do Not Commit To

- **Third-party payment processor latency.** We measure our own service's response time, not the latency of the upstream payment gateway we call. A slowdown on their end will show up in our p95 but is out of our control and out of scope for this SLO.
- **Client-side (browser/mobile) load time.** These SLIs cover server-side availability and processing only. Time-to-interactive on the customer's device, network conditions between the customer and our edge, and client rendering performance are not measured here.
