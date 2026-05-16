---
name: Split multi-file refactors into phase commits, each independently green
description: For features touching 5+ files, never push one giant commit. Split into Phase a/b/c... where each phase compiles + lints + builds independently.
type: feedback
---
For any feature spanning 5+ files or both backend + frontend, split into per-phase commits where each individual commit keeps the build green.

**Why:** Phase 6 (dashboard wiring) was 3 commits (6a/6b/6c — frontend layered). Phase 8 (chat sessions) was 6 commits (plan + 8a backend schema + 8b/1 routes + 8b/2 rewrite + 8c frontend + 8d+e layout). Each commit was buildable; a lint failure on 8d+e was fixable with one extra commit on top instead of rewinding the whole feature.

**How to apply:**

1. **Numbering:** `(Phase Na)`, `(Phase Nb)`, `(Phase Nb/1)`, `(Phase Nb/2)`. The slash sub-numbering is for when one phase exceeds the [25KB push budget](feedback_github_push_fallback.md) and gets split for transport, not logic.
2. **Independence rule:** if the new commit only touches additive files (new endpoint, new component), it's safe alone. If it modifies a contract used elsewhere, the next-phase consumer must land in the same push or right after — order matters.
3. **Backend before frontend:** schema → repo → schema-pydantic → route → frontend types → frontend hooks → frontend UI.
4. **Push cadence:** push each phase to GitHub immediately after typecheck/lint passes locally. Don't batch — small frequent pushes mean CI catches issues before the whole feature is "done".
5. **Commit message body:** list the files touched + 1-line description of each behavior change.

Avoid: one mega-commit of 17 files. It's harder to review, harder to bisect, and a single lint error blocks the whole thing.
