---
name: Screenshot fallback when browser-harness can't connect
description: When browser-harness needs Chrome remote-debug enabled (it isn't), fall back to headless playwright via a tiny node script.
type: feedback
---
`browser-harness` requires Chrome to have remote debugging enabled. On a remote Linux server there may be no desktop Chrome at all. Don't ask the user to enable it — fall back to playwright headless.

**How to apply:**

1. **Check first:** if `browser-harness -c 'page_info()'` errors with `DevToolsActivePort not found`, switch immediately.

2. **One-time setup:**
```bash
cd /tmp && npm install playwright && npx playwright install chromium
```

3. **Save this as `/tmp/screenshot.mjs`:**
```js
import { chromium } from "playwright";
const url = process.argv[2];
const out = process.argv[3] || "/tmp/shot.png";
const fullPage = process.argv[4] === "full";
const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: 1440, height: 900 }, deviceScaleFactor: 1 });
const page = await ctx.newPage();
await page.goto(url, { waitUntil: "domcontentloaded" });   // NOT "networkidle" — Clerk polls forever
await page.waitForTimeout(3500);                            // give Clerk + framer-motion time to settle
await page.screenshot({ path: out, fullPage });
await browser.close();
console.log("OK", out);
```

4. **Use:**
```bash
node /tmp/screenshot.mjs http://localhost:3000/preview /tmp/shot.png       # viewport
node /tmp/screenshot.mjs http://localhost:3000/preview /tmp/shot.png full  # full page
```

**Gotchas:**
- `waitUntil: "networkidle"` never resolves on Clerk-protected pages. Use `domcontentloaded` + a 3–4s `waitForTimeout`.
- Playwright MCP may not find Chrome at `/opt/google/chrome/chrome` — using a local chromium via the script above is simpler.
- `npx playwright install chromium --with-deps` needs root. Plain `npx playwright install chromium` works without.
