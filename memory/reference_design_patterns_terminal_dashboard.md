---
name: Reusable design+code patterns for terminal-style dashboards
description: Concrete code patterns for Next.js + Tailwind v4 + shadcn — shooting-star chart animation, SectionFrame chrome, dev-only preview routes, mock-data-first flow.
type: reference
---
Drop-in usable for any future Next.js + Tailwind v4 + shadcn project that wants a terminal/agentic-OS feel.

**1. Shooting-star dot animating along a line chart**

Don't fight Recharts' internals. Render the area chart with a custom SVG (Catmull-Rom-smoothed cubic Bezier path) and animate with framer-motion (`motion@12+`):

```tsx
const progress = useMotionValue(0);
useLayoutEffect(() => {
  const len = pathRef.current.getTotalLength();
  setPathLen(len);
  progress.set(0);
  const ctrl = animate(progress, 1, { duration: 1.7, ease: [0.16, 1, 0.3, 1] });
  return () => ctrl.stop();
}, [linePath]);

const dashOffset = useTransform(progress, p => pathLen * (1 - p));
const dotX = useTransform(progress, p => pathRef.current?.getPointAtLength(pathLen * p).x ?? 0);
const dotY = useTransform(progress, p => pathRef.current?.getPointAtLength(pathLen * p).y ?? 0);

<motion.path strokeDasharray={pathLen} style={{ strokeDashoffset: dashOffset }} />
<motion.circle r={5} filter="url(#glow)" style={{ cx: dotX, cy: dotY, opacity: headOpacity }} />
```

Use `useTransform` (not `useState` + `useAnimationFrame`) so the circle updates outside React render cycle.

Catmull-Rom smoothing helper:
```ts
function smoothPath(pts){ const d=[`M ${pts[0].x} ${pts[0].y}`]; for(let i=0;i<pts.length-1;i++){ const p0=pts[i-1]??pts[i],p1=pts[i],p2=pts[i+1],p3=pts[i+2]??p2; d.push(`C ${p1.x+(p2.x-p0.x)/6} ${p1.y+(p2.y-p0.y)/6}, ${p2.x-(p3.x-p1.x)/6} ${p2.y-(p3.y-p1.y)/6}, ${p2.x} ${p2.y}`); } return d.join(" "); }
```

**2. SectionFrame — global card chrome**

```tsx
<SectionFrame label="追蹤趨勢" meta="Δ +127" actions={<Segmented .../>} bodyClassName="p-2">
  ...content
</SectionFrame>
```

The frame is `border border-border bg-card rounded-sm hover:border-primary/30`. Header is `font-mono text-[11px] tracking-[0.18em] uppercase`.

**3. Dev-only `/preview/*` route for design iteration**

In `middleware.ts`:
```ts
const publicRoutes = ["/sign-in(.*)", "/sign-up(.*)", "/api/health"];
if (process.env.NODE_ENV !== "production") {
  publicRoutes.push("/preview(.*)");
}
```

Mirror your `/` page tree under `/preview/` (just an import). Lets you screenshot without going through Clerk every time. Auto-disabled in prod.

**4. Mock-data-first**

Single file at `lib/mock-data.ts` exports every dataset the dashboard reads. Realistic curves via `Math.sin(seed) - floor` for deterministic noise:
```ts
const seed = (n) => Math.sin(n * 12.9898) * 43758.5453;
const rand = (n) => seed(n) - Math.floor(seed(n));
```
Component imports `import { followerSeries, kpis, scripts } from "@/lib/mock-data"`. Phase C swaps imports for fetch calls to backend.

**5. Animated counter on KPI cards**

```tsx
const motionVal = useMotionValue(0);
const display = useTransform(motionVal, v => format(v));
useEffect(() => animate(motionVal, value, { duration: 0.9 }).stop, [value]);
return <motion.span>{display}</motion.span>;
```

**6. Stagger reveal**

`transition={{ delay: 0.04 * index, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}` on each child. 0.04s is the sweet spot.

**7. Tailwind v4 + shadcn dark-default tokens**

```css
:root, .dark {
  --background: oklch(0.06 0 0);
  --primary: oklch(0.68 0.18 42);
  --radius: 2px;
}
```
Use `<html class="dark">` so `dark:` Tailwind variants still work.

**8. Clerk dark theme**

```tsx
import { dark } from "@clerk/themes";
<ClerkProvider appearance={{ baseTheme: dark, variables: { colorPrimary: "oklch(0.68 0.18 42)", colorBackground: "oklch(0.10 0 0)", borderRadius: "2px" }, elements: { card: "border border-[oklch(0.22_0_0)] shadow-none", formButtonPrimary: "bg-[oklch(0.68_0.18_42)] hover:bg-[oklch(0.72_0.18_42)] text-black font-mono uppercase tracking-widest text-xs" } }}>
```
