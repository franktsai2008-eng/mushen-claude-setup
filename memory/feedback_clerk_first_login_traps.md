---
name: Clerk first-login traps (Next.js + email allowlist middleware)
description: Three Clerk gotchas. Apply when integrating Clerk into a Next.js app gated by an email allowlist in middleware.
type: feedback
---
When standing up a Next.js app with `clerkMiddleware` + an email allowlist, these three things break the first-login flow in ways that look like "Clerk is broken" but are actually default behavior.

**How to apply:**

1. **Default Clerk session token does NOT include email** — `clerkMiddleware` exposes `sessionClaims` but the default JWT only has `sub`, `iat`, `exp`, etc. — no `email`. Code that does `sessionClaims?.email` returns undefined → allowlist check fails → silent 403. Fix in **Clerk Dashboard → Sessions → Customize session token**:
   ```json
   {
     "email": "{{user.primary_email_address}}"
   }
   ```
   One-time per-Clerk-app config. There is no way to do it in code; it must be done in the dashboard.

2. **Don't redirect to Clerk Account Portal — build local /sign-in and /sign-up routes** — `redirectToSignIn()` defaults to Clerk's hosted Account Portal which is sign-in only by default, so first-time users with no existing Clerk user get "User not found". Build local pages with Clerk's catch-all routing:
   ```
   apps/web/src/app/sign-in/[[...sign-in]]/page.tsx
   apps/web/src/app/sign-up/[[...sign-up]]/page.tsx
   ```
   Each is just `<SignIn />` or `<SignUp />`.

3. **Wire 4 Clerk URL env vars on the host (Vercel/etc.)**:
   ```
   NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
   NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
   NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL=/
   NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL=/
   ```

**Dev vs prod keys:**
- `pk_test_...` (dev): Clerk auto-trusts any host at runtime.
- `pk_live_...` (prod): MUST add the production domain in **Clerk Dashboard → Configure → Domains**.
