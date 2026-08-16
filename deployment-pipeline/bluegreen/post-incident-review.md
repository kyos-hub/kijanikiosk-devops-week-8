# Post-Incident Review: Pipeline Targeted Wrong Environment During Investor Demo

## 1. Incident Summary
During a live demonstration to investors, our deployment tool sent an update to the wrong version of the website, which made the demo site unavailable for about 48 seconds. No customer-facing production traffic was affected. The issue was caught and corrected quickly, but it happened in front of an audience we could not afford to have it happen in front of.

## 2. Timeline (reconstructed)

| Time | Event |
|---|---|
| 09:14 (estimated, ±1 min — based on the walkthrough start noted in the demo run sheet) | Investor walkthrough begins; presenter starts narrating the staging environment. |
| 09:15 | Pipeline triggered to deploy a demo-prep update. |
| 09:15:xx | Pipeline targets the wrong environment (staging shares a deploy target with a pre-prod environment due to a naming gap — see Root Cause). |
| 09:16 (estimated, ±1 min — based on the narrative stating errors appeared within a minute of the trigger) | Staging begins returning errors; presenter notices the page fail to load. |
| 09:16:30 (estimated) | On-call engineer notified via Slack by the presenter. |
| 09:17 (estimated) | Engineer identifies the pipeline ran against the wrong target and manually re-triggers against the correct environment. |
| 09:17:48 (estimated, based on the 48-second unavailability window) | Staging confirmed responsive again; presenter resumes. |

## 3. Root Cause

Surface finding: the pipeline targeted the wrong environment.

- **Why did the pipeline target the wrong environment?** Because the environment name passed to the pipeline (`staging`) matched a config alias that also resolved to a pre-prod target.
- **Why did one name resolve to two targets?** Because environment-to-target mapping was defined in two places — a pipeline default and a per-job override — and they had drifted out of sync.
- **Why had they drifted out of sync?** Because there was no single source of truth for environment mappings; each pipeline job could define its own override, and no validation caught the mismatch.
- **Why was there no validation?** Because environment targeting was treated as a low-risk configuration value, not as a first-class deployment input requiring the same review and testing as application code.

**Structural finding:** the deployment system allowed environment identity to be defined redundantly, in multiple places, with no reconciliation check — so a single ambiguous name could route real traffic changes to the wrong target with no warning.

## 4. Contributing Factors

- No automated check comparing the pipeline default environment map against per-job overrides before a run.
- The demo was scheduled shortly before the deploy, leaving no buffer to catch a target-resolution issue in a dry run.
- No environment-name confirmation step (e.g., a required manual approval showing "deploying to: X") existed in the pipeline UI, so nothing surfaced the wrong target before it ran.

## 5. What Went Well

- The presenter recognized the failure immediately and escalated within roughly a minute rather than trying to debug it live, which kept the outage window short.
- The correct environment recovered cleanly once the engineer re-triggered against the right target — no data corruption or partial-state issues resulted.

## 6. Action Items

| Owner | Action | Target |
|---|---|---|
| Platform engineer | Consolidate environment-to-target mapping into a single config file read by all pipeline jobs, removing per-job override capability | 2 weeks |
| Platform engineer | Add a pre-run validation step that fails the pipeline if the resolved target doesn't match an explicit allowlist for the requested environment name | 3 weeks |
| Engineering lead | Require a "deploying to: <target>" confirmation step in the pipeline UI for any deploy triggered within 2 hours of a scheduled demo or presentation | 1 week |
