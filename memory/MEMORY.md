# 通用工程經驗（含初始一組來自共享經驗）

# ── 部署陷阱 ──
- [Railway monorepo deploy traps](feedback_railway_deploy_traps.md) — six gotchas: Watch Paths auto-wrong, Target Port 8080 not 8000, DATABASE_URL must be Reference, driver-less URL needs normalize, SKIPPED deploys, diagnose from logs first.
- [Vercel monorepo deploy traps](feedback_vercel_deploy_traps.md) — pin pnpm@9.15.4, override stored buildCommand, self-contained workspace package.json, explicit project name on link.
- [Vercel manual deploy verify](feedback_vercel_manual_deploy.md) — never assume git push triggers Vercel. Always `list_deployments` after push.
- [Schedule wakeup / background bash for deploys](feedback_schedule_wakeup_for_deploys.md) — never tight-poll Vercel/Railway. Background `until` loop for one notification, ScheduleWakeup(180s) for "check back later".

# ── Clerk / Auth ──
- [Clerk first-login traps](feedback_clerk_first_login_traps.md) — customize session token for email claim, build local /sign-in + /sign-up pages, wire 4 NEXT_PUBLIC_CLERK_* env vars.
- [Clerk-protected actions via DevTools fetch](feedback_clerk_action_via_devtools_fetch.md) — when an action needs Clerk JWT, give user a one-line `await fetch(...)` they run in browser DevTools console.

# ── Git / GitHub ──
- [GitHub push fallback to MCP](feedback_github_push_fallback.md) — when `git push` 403s, switch to mcp__github__push_files in batches of 6 files / ≤25KB per call.
- [mcp push doesn't update local HEAD](feedback_mcp_push_local_head_divergence.md) — after `mcp__github__push_files`, `git status` lies; treat `mcp__github__list_commits` as authority for what's on main.
- [Phase-split commits](feedback_phase_split_commits.md) — for 5+ file refactors, split into Na/Nb/Nc commits each independently green.
- [Cross-session push completeness](feedback_cross_session_push_completeness.md) — when committing work started in another session, `git status -s` to verify ALL files match the feature's full surface.

# ── Build / Lint ──
- [Pre-push verification gates](feedback_pre_push_verification_gates.md) — typecheck + lint + build all green before push.
- [Lint with clean rebuild before push](feedback_lint_clean_rebuild_before_push.md) — Vercel runs ESLint with no cache; `rm -rf .next && pnpm build` before claiming green.

# ── 開發工作流 ──
- [4-phase UI overhaul workflow](feedback_ui_overhaul_workflow.md) — A foundation → B mock-data sections → C real-data wire → D polish other pages.
- [Backend-first ordering](feedback_backend_first_ordering.md) — schema → repo → route → frontend types → frontend UI.
- [Match existing patterns](feedback_match_existing_patterns.md) — read 2–3 sibling files before adding new model/route/component.
- [Plan-doc-as-resumption-anchor](feedback_plan_doc_anchor.md) — push PLAN-XXX.md to repo as the FIRST commit of any multi-phase feature.
- [Session handoff pattern](feedback_session_handoff_pattern.md) — when context fills mid-feature, hand off via 3 artifacts: PLAN doc + project memory file + copy-paste prompt for fresh session.
- [Resume from JSONL transcript](feedback_resume_from_jsonl_transcript.md) — parse `~/.claude/projects/-home-$(whoami)/<sessionId>.jsonl` before guessing.

# ── 工具/Agent 原則 ──
- [MCP-first principle](feedback_mcp_first_principle.md) — if MCP can do it, use MCP.
- [Audit config before syncing](feedback_audit_config_before_syncing.md) — before updating env var X on N services, grep each codebase to verify X is actually read.
- [No silent tool-call replies in chat agents](feedback_chat_no_silent_tool.md) — system prompts must force a text reply alongside any tool call.
- [claude-agent-sdk needs non-root in containers](feedback_claude_agent_sdk_non_root.md) — bundled Claude CLI hard-stops on uid=0.
- [Dashboard imports mock data](feedback_dashboard_uses_mock_data.md) — when dashboard numbers don't change after sync, grep for `mock-data` imports first.
- [Screenshot fallback to playwright](feedback_screenshot_when_browser_harness_blocked.md) — when browser-harness blocked, use headless playwright; `domcontentloaded` not `networkidle` for Clerk.
- [Proactive long-term memory recall](feedback_proactive_memory_recall.md) — 任務涉及客戶/產品/策略/continuation 時主動查 Pinecone。
- [Insights log pattern](feedback_insights_log.md) — when a run surfaces something cross-cutting, propose a #NNN entry in docs/INSIGHTS.md.

# ── 設計參考 ──
- [Terminal dashboard design patterns](reference_design_patterns_terminal_dashboard.md) — shooting-star SVG path animation, SectionFrame chrome, OKLCH dark tokens, Clerk dark theme.

# ── 你自己的記憶 (從這裡開始往下加) ──
<!--
新增格式範例:
- [標題](檔名.md) — 一句話描述

對應檔案放在同層目錄，frontmatter:
---
name: short-kebab-slug
description: 一句話描述
metadata:
  type: feedback | project | reference | user
---
-->
