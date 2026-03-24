---
name: performance-precision
description: Web performance optimization for React/Next.js applications. Core Web Vitals (LCP, INP, CLS), code splitting, lazy loading, image optimization, render optimization (useMemo, useCallback, React.memo), memory management, bundle analysis. Use when optimizing page speed, fixing slow renders, reducing bundle size, improving Lighthouse scores, or debugging memory leaks.
---

# Performance Precision ⚡

> Achieve blazing-fast web applications with precision optimization.

---

## 1. Core Web Vitals (2025)

### Current Metrics

| Metric | Measures | Good | Needs Improvement | Poor |
|--------|----------|------|-------------------|------|
| **LCP** | Loading | ≤ 2.5s | 2.5s - 4s | > 4s |
| **INP** | Interactivity | ≤ 200ms | 200ms - 500ms | > 500ms |
| **CLS** | Visual Stability | ≤ 0.1 | 0.1 - 0.25 | > 0.25 |

> **Note**: INP (Interaction to Next Paint) replaced FID in March 2024.

### What Each Metric Means

| Metric | Definition |
|--------|------------|
| LCP (Largest Contentful Paint) | Time until largest content element is visible |
| INP (Interaction to Next Paint) | Latency of all user interactions during session |
| CLS (Cumulative Layout Shift) | Sum of unexpected layout shifts |

---

## 2. LCP Optimization

### Common LCP Elements

- Hero images
- Large text blocks (h1, p)
- Video poster images
- Background images via CSS

### Optimization Strategies

| Strategy | Implementation |
|----------|----------------|
| **Optimize LCP resource** | Compress and use modern formats (WebP/AVIF) |
| **Eliminate render-blocking** | Defer non-critical CSS/JS |
| **Reduce server response time** | Use CDN, optimize TTFB |
| **Preload critical resources** | `<link rel="preload">` for LCP image |
| **Use priority hints** | `fetchpriority="high"` on LCP image |

### Next.js Image Optimization

```tsx
import Image from "next/image";

// Hero image (above fold) - prioritize
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority  // Preloads, disables lazy loading
  sizes="100vw"
/>

// Below fold - lazy load (default)
<Image
  src="/product.jpg"
  alt="Product"
  width={400}
  height={300}
  loading="lazy"  // Default behavior
  placeholder="blur"
  blurDataURL={blurPlaceholder}
/>
```

### Font Optimization

```tsx
// next.config.js - Auto font optimization
import { Inter } from "next/font/google";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",  // Prevent FOIT
  preload: true,
});
```

```html
<!-- Manual preload -->
<link
  rel="preload"
  href="/fonts/inter.woff2"
  as="font"
  type="font/woff2"
  crossorigin
/>
```

---

## 3. INP Optimization

### What Causes Poor INP

| Cause | Solution |
|-------|----------|
| Long JavaScript tasks (>50ms) | Break into smaller chunks |
| Heavy event handlers | Debounce/throttle |
| Synchronous third-party scripts | Load async/defer |
| Complex DOM | Simplify structure |

### Breaking Long Tasks

```tsx
// ❌ Bad: Blocks main thread
function processLargeArray(items) {
  items.forEach(item => heavyOperation(item));
}

// ✅ Good: Yield to main thread
async function processLargeArray(items) {
  for (const item of items) {
    heavyOperation(item);
    
    // Yield every 4ms (before 50ms threshold)
    if (performance.now() % 50 < 4) {
      await yieldToMain();
    }
  }
}

function yieldToMain() {
  return new Promise(resolve => {
    setTimeout(resolve, 0);
  });
}
```

### Using Web Workers

```tsx
// heavy-worker.ts
self.onmessage = (e) => {
  const result = expensiveCalculation(e.data);
  self.postMessage(result);
};

// Component
const worker = useMemo(() => new Worker(
  new URL("./heavy-worker.ts", import.meta.url)
), []);

useEffect(() => {
  worker.onmessage = (e) => setResult(e.data);
  return () => worker.terminate();
}, [worker]);
```

### Debounce/Throttle

```tsx
import { useDebouncedCallback } from "use-debounce";

function SearchInput() {
  const debouncedSearch = useDebouncedCallback(
    (term) => fetchResults(term),
    300  // Wait 300ms after last keystroke
  );

  return <input onChange={(e) => debouncedSearch(e.target.value)} />;
}
```

---

## 4. CLS Optimization

### Common CLS Causes

| Cause | Fix |
|-------|-----|
| Images without dimensions | Set `width`/`height` or `aspect-ratio` |
| Ads/embeds without reserved space | Use placeholder containers |
| Dynamic content insertion | Reserve space or use CSS containment |
| Web fonts causing FOIT/FOUT | Use `font-display: swap` + preload |
| Animations changing layout | Use `transform` instead of position |

### Reserve Space for Images

```tsx
// ✅ Always specify dimensions
<Image
  src="/photo.jpg"
  width={800}
  height={600}
  alt="Photo"
/>

// Or use aspect-ratio
<div style={{ aspectRatio: "16/9" }}>
  <Image src="/video-thumb.jpg" fill alt="Video" />
</div>
```

### Reserve Space for Dynamic Content

```tsx
// ✅ Reserve space for skeleton
function ProductCard({ product }) {
  if (!product) {
    return <div className="h-64 w-full bg-gray-200 animate-pulse" />;
  }
  
  return (
    <div className="h-64 w-full">
      {/* Content */}
    </div>
  );
}
```

### CSS Containment

```css
/* Isolate repaints to this element */
.card {
  contain: layout style paint;
}

/* For widgets with fixed size */
.widget {
  contain: strict;
  width: 300px;
  height: 200px;
}
```

---

## 5. Code Splitting & Lazy Loading

### Dynamic Imports (React)

```tsx
import { lazy, Suspense } from "react";

// Lazy load heavy components
const HeavyChart = lazy(() => import("./HeavyChart"));

function Dashboard() {
  return (
    <Suspense fallback={<ChartSkeleton />}>
      <HeavyChart />
    </Suspense>
  );
}
```

### Next.js Dynamic Import

```tsx
import dynamic from "next/dynamic";

// Client-only component (no SSR)
const MapComponent = dynamic(
  () => import("./MapComponent"),
  { 
    ssr: false,
    loading: () => <MapSkeleton />
  }
);

// Heavy chart library
const Chart = dynamic(
  () => import("react-chartjs-2").then((mod) => mod.Chart),
  { loading: () => <ChartSkeleton /> }
);
```

### When to Use Dynamic Import

| Scenario | Example |
|----------|---------|
| Heavy libraries | Chart.js, PDF viewers, Rich text editors |
| Conditionally shown UI | Modals, Drawers, Tabs content |
| Below-the-fold content | Comments section, Related products |
| Admin-only features | Admin dashboard components |
| Browser-only APIs | Components using `window`, `document` |

### Route-Based Splitting (Next.js)

```
app/
├── page.tsx           # Main bundle
├── dashboard/
│   └── page.tsx       # Separate bundle (auto-split)
└── admin/
    └── page.tsx       # Separate bundle (auto-split)
```

---

## 6. Render Optimization

### When to Use Each Hook

| Hook | Use When |
|------|----------|
| `useMemo` | Expensive calculations |
| `useCallback` | Passing callbacks to memoized children |
| `React.memo` | Pure components with expensive renders |

### Decision Flowchart

```
Is this a performance problem?
├── No → Don't optimize
└── Yes → 
    Is it an expensive calculation?
    ├── Yes → useMemo
    └── No →
        Is it a function passed to React.memo child?
        ├── Yes → useCallback
        └── No →
            Is the component pure and expensive to render?
            ├── Yes → React.memo
            └── No → Look elsewhere
```

### useMemo

```tsx
// ✅ Good: Expensive filter/sort
const sortedItems = useMemo(
  () => items.sort((a, b) => a.name.localeCompare(b.name)),
  [items]
);

// ❌ Bad: Simple calculation
const doubled = useMemo(() => value * 2, [value]);
// Just use: const doubled = value * 2;
```

### useCallback

```tsx
// ✅ Good: Passed to memoized child
const handleClick = useCallback(() => {
  doSomething(id);
}, [id]);

<MemoizedButton onClick={handleClick} />

// ❌ Bad: Not passed to memoized component
const handleClick = useCallback(() => {
  setCount(c => c + 1);
}, []); // Unnecessary overhead
```

### React.memo

```tsx
// ✅ Good: Expensive pure component
const ExpensiveList = React.memo(function ExpensiveList({ items }) {
  return items.map(item => <ExpensiveItem key={item.id} item={item} />);
});

// With custom comparison
const Item = React.memo(
  function Item({ item }) { /* ... */ },
  (prevProps, nextProps) => prevProps.item.id === nextProps.item.id
);
```

### Anti-Patterns

```tsx
// ❌ Creating objects inline breaks memoization
<MemoizedComponent style={{ color: "red" }} />

// ✅ Stable reference
const style = useMemo(() => ({ color: "red" }), []);
<MemoizedComponent style={style} />

// ❌ Defining components inside render
function Parent() {
  // This creates NEW component every render!
  function Child() { return <div />; }
  return <Child />;
}

// ✅ Define outside
function Child() { return <div />; }
function Parent() {
  return <Child />;
}
```

---

## 7. Memory Management

### useEffect Cleanup

```tsx
useEffect(() => {
  // Timer
  const timer = setInterval(tick, 1000);
  
  // Event listener
  window.addEventListener("resize", handleResize);
  
  // Subscription
  const subscription = dataSource.subscribe(handleData);
  
  // Cleanup function
  return () => {
    clearInterval(timer);
    window.removeEventListener("resize", handleResize);
    subscription.unsubscribe();
  };
}, []);
```

### Cancelling Fetch Requests

```tsx
useEffect(() => {
  const controller = new AbortController();

  async function fetchData() {
    try {
      const response = await fetch(url, { signal: controller.signal });
      const data = await response.json();
      setData(data);
    } catch (error) {
      if (error.name !== "AbortError") {
        setError(error);
      }
    }
  }

  fetchData();

  return () => controller.abort();
}, [url]);
```

### Common Memory Leak Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| setInterval without cleanup | Keeps running after unmount | Clear in cleanup |
| Event listeners | Stay attached | Remove in cleanup |
| WebSocket connections | Stay open | Close in cleanup |
| Stale closures | Hold old references | Use refs for latest values |
| Large objects in state | Never released | Clear when not needed |

### Detecting Memory Leaks

1. Open Chrome DevTools → Memory tab
2. Take heap snapshot before action
3. Perform action (navigate, open modal, etc.)
4. Force garbage collection (click 🗑️)
5. Take another snapshot
6. Compare snapshots → Look for growth

---

## 8. Bundle Analysis

### Tools

| Tool | Purpose |
|------|---------|
| `@next/bundle-analyzer` | Visualize Next.js bundles |
| `source-map-explorer` | Analyze bundle composition |
| `bundlephobia.com` | Check package sizes before installing |

### Next.js Bundle Analyzer Setup

```js
// next.config.js
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});

module.exports = withBundleAnalyzer({
  // config
});
```

```bash
ANALYZE=true npm run build
```

### Import Cost Awareness

```tsx
// ❌ Imports entire library (50KB+)
import { format } from "date-fns";

// ✅ Tree-shakeable import
import format from "date-fns/format";

// ❌ Full lodash (70KB+)
import { debounce } from "lodash";

// ✅ Individual import (4KB)
import debounce from "lodash/debounce";
```

---

## 9. Network Optimization

### Resource Hints

```html
<!-- Preconnect to critical origins -->
<link rel="preconnect" href="https://fonts.googleapis.com" />
<link rel="preconnect" href="https://api.example.com" />

<!-- DNS prefetch for less critical -->
<link rel="dns-prefetch" href="https://analytics.example.com" />

<!-- Preload critical resources -->
<link rel="preload" href="/critical.css" as="style" />
<link rel="preload" href="/hero.jpg" as="image" />

<!-- Prefetch next page -->
<link rel="prefetch" href="/next-page.js" />
```

### Next.js Prefetching

```tsx
import Link from "next/link";

// Automatic prefetch on viewport (default)
<Link href="/products">Products</Link>

// Disable prefetch for less important links
<Link href="/terms" prefetch={false}>Terms</Link>
```

### Caching Strategies

| Strategy | Use Case | Example |
|----------|----------|---------|
| **SWR (Stale-While-Revalidate)** | API data | TanStack Query, SWR |
| **Cache-First** | Static assets | Images, fonts |
| **Network-First** | Fresh data critical | Real-time prices |
| **Cache-Only** | Offline content | Installed PWA assets |

---

## 10. Measurement Tools

### Lighthouse

```bash
# CLI
npx lighthouse https://example.com --output html

# Chrome DevTools → Lighthouse tab
```

### Web Vitals Library

```tsx
import { onLCP, onINP, onCLS } from "web-vitals";

onLCP(console.log);
onINP(console.log);
onCLS(console.log);

// Send to analytics
function sendToAnalytics(metric) {
  const body = JSON.stringify(metric);
  navigator.sendBeacon("/analytics", body);
}

onLCP(sendToAnalytics);
```

### React DevTools Profiler

1. Open React DevTools → Profiler tab
2. Click Record
3. Interact with app
4. Stop recording
5. Analyze render times and commit info

---

## 11. Quick Reference

### Performance Checklist

- [ ] LCP image has `priority` attribute
- [ ] Images have explicit `width`/`height`
- [ ] Fonts are preloaded with `display: swap`
- [ ] Heavy components are lazy loaded
- [ ] Third-party scripts are `async`/`defer`
- [ ] No unnecessary re-renders (check Profiler)
- [ ] useEffect has proper cleanup
- [ ] Bundle size analyzed and optimized

### Common Fixes by Symptom

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Slow initial load | Large bundle | Code splitting |
| Slow LCP | Unoptimized images | next/image, preload |
| Janky scrolling | Heavy paint/layout | CSS containment, virtualization |
| Slow interactions | Main thread blocked | Web Workers, scheduler.yield() |
| Memory growth | Leaking listeners | Proper cleanup |
| Cumulative shifts | Missing dimensions | Reserve space |

---

## 12. Advanced Patterns

For detailed implementations:

- **React Rendering Deep Dive**: See [references/react-rendering.md](references/react-rendering.md)
- **Image & Font Strategies**: See [references/media-optimization.md](references/media-optimization.md)
- **Memory Leak Debugging**: See [references/memory-debugging.md](references/memory-debugging.md)
- **Bundle Optimization**: See [references/bundle-optimization.md](references/bundle-optimization.md)

---

> **Remember:** Measure before optimizing. Use DevTools Profiler and Lighthouse to identify real bottlenecks, not perceived ones.
