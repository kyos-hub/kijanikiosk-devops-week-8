# Environment Notes

This project was completed inside a GitHub Codespace, which runs as a container
without a functioning systemd (`systemctl` reports: `"systemd" is not running in
this container due to its overhead`). No separate staging VM was provisioned for
this assignment.

To keep the deployment behavior faithful to the assignment's intent, the
`kk-api-blue.service` / `kk-api-green.service` systemd units were replaced with
a minimal PID-file-based process manager:

- `kk-infra/scripts/deploy-app.sh` starts the app as a background process and
  records its PID, functionally equivalent to `systemctl start`.
- `kk-infra/scripts/is-active.sh <env>` checks whether that PID is alive,
  functionally equivalent to `systemctl is-active`.

Everything else matches the assignment as written: nginx performs the actual
traffic switch and is the thing being reloaded/tested, `.active-env` and
`.previous-env` state files are written and read exactly as specified,
`post-deploy-monitor.sh` polls the live health endpoint every 5 seconds and
triggers `switch-env.sh` automatically on 3 consecutive failures with no
human action in between, and all timestamps in the evidence files come from
commands actually run against this environment.
