---
name: Screenshot fallback when browser-harness can't connect
description: When browser-harness needs Chrome remote-debug enabled (it isn't), don't try to enable it — fall back to headless playwright via a tiny node script.
type: feedback
---
`browser-harness` is the default for design iteration screenshots, but it requires user's Chrome to have remote debugging enabled. On a remote Linux server they likely don't have a desktop Chrome at all. Don't ask them to enable it — fall back to playwright headless.

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
await page.goto(url, { waitUntil: "domcontentloaded" });
await page.waitForTimeout(3500);
await page.screenshot({ path: out, fullPage });
await browser.close();
console.log("OK", out);
```

4. **Use:**
```bash
node /tmp/screenshot.mjs http://localhost:3000/preview /tmp/shot.png       # viewport
node /tmp/screenshot.mjs http://localhost:3000/preview /tmp/shot.png full  # full page
```

5. **Then `Read /tmp/shot.png`** to view it inline.

**Gotchas:**
- `waitUntil: "networkidle"` never resolves on Clerk-protected pages. Use `domcontentloaded` + `waitForTimeout`.
- For full-page screenshots, set `deviceScaleFactor: 1` to keep image dimensions modest.

**Don't:** try `npx playwright install chromium --with-deps` without sudo. Plain `npx playwright install chromium` works without root.
