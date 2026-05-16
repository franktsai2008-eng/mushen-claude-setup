---
name: claude-agent-sdk needs non-root in containers
description: When using claude-agent-sdk's permission_mode="bypassPermissions" inside a container, the bundled Claude CLI hard-stops on uid=0. Container must run as non-root.
type: feedback
---

The Python `claude-agent-sdk` ships a bundled Claude CLI that runs as a subprocess. When the SDK is configured with `permission_mode="bypassPermissions"`, the SDK invokes that CLI with `--dangerously-skip-permissions`. The CLI itself refuses to run that flag while uid=0 — it exits 1 immediately with `--dangerously-skip-permissions cannot be used with root/sudo privileges for security reasons`.

**Why:** The bundled Claude CLI has a hard security check that aborts when it detects sudo/root. The check is inside the CLI binary, not the SDK, so no Python-side flag can override it.

**How to apply:** Any Dockerfile that runs an app calling `claude-agent-sdk` with `bypassPermissions` MUST add `USER` to a non-root account. Pattern:

```dockerfile
RUN useradd --create-home --shell /bin/bash --uid 1001 app \
  && mkdir -p /app && chown -R app:app /app
WORKDIR /app
USER app
COPY --chown=app:app ...
```

Symptom on Railway/Docker: SSE returns `event: session` then `event: error` with message `Command failed with exit code 1`. Logs show `Using bundled Claude Code CLI: .../_bundled/claude` followed immediately by the security message.
