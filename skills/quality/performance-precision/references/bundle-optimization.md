# Bundle Optimization Guide

> Reduce JavaScript bundle size for faster loading.

---

## Table of Contents

1. [Analyzing Your Bundle](#analyzing-your-bundle)
2. [Code Splitting Strategies](#code-splitting-strategies)
3. [Import Optimization](#import-optimization)
4. [Third-Party Library Optimization](#third-party-library-optimization)
5. [Build Configuration](#build-configuration)

---

## Analyzing Your Bundle

### Next.js Bundle Analyzer

```bash
npm install @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require("@next/bundle-analyzer")({
  enabled: process.env.ANALYZE === "true",
});

module.exports = withBundleAnalyzer({
  // your config
});
```

```bash
ANALYZE=true npm run build
# Opens visualization in browser
```

### Source Map Explorer

```bash
npm install source-map-explorer

# Build with source maps
npm run build

# Analyze
npx source-map-explorer .next/static/chunks/*.js
```

### Bundlephobia (Pre-install Check)

Before adding a dependency:
1. Visit [bundlephobia.com](https://bundlephobia.com)
2. Search for package name
3. Check:
   - **Minified size** - Total download
   - **Gzipped size** - Actual transfer
   - **Tree-shakeable** - Can unused exports be removed?

---

## Code Splitting Strategies

### Route-Based Splitting (Automatic in Next.js)

```
app/
├── page.tsx           # Bundle: /
├── about/
│   └── page.tsx       # Bundle: /about
├── dashboard/
│   └── page.tsx       # Bundle: /dashboard
└── admin/
    └── page.tsx       # Bundle: /admin
```

Each route gets its own bundle. Users only download what they visit.

### Component-Based Splitting

```tsx
import dynamic from "next/dynamic";

// Split heavy components
const HeavyEditor = dynamic(() => import("./HeavyEditor"), {
  loading: () => <EditorSkeleton />,
});

const DataChart = dynamic(() => import("./DataChart"), {
  ssr: false, // Client-only (uses window)
  loading: () => <ChartSkeleton />,
});

// Conditional loading
function AdminPanel({ isAdmin }) {
  const AdminDashboard = dynamic(() => import("./AdminDashboard"));
  
  if (!isAdmin) return null;
  return <AdminDashboard />;
}
```

### Library Splitting

```tsx
// ❌ Loads library immediately
import { Chart } from "chart.js";

// ✅ Loads library on demand
const ChartComponent = dynamic(
  () => import("chart.js").then((mod) => {
    // Register what you need
    mod.Chart.register(...mod.registerables);
    return { default: MyChart };
  })
);
```

---

## Import Optimization

### Named vs Default Imports

```tsx
// ❌ May import entire library (depends on library)
import { debounce } from "lodash";

// ✅ Direct path import (guaranteed tree-shake)
import debounce from "lodash/debounce";

// ✅ Or use lodash-es (ES modules, tree-shakeable)
import { debounce } from "lodash-es";
```

### Date Libraries

```tsx
// ❌ date-fns: Potential full import
import { format, parseISO } from "date-fns";

// ✅ date-fns: Direct imports
import format from "date-fns/format";
import parseISO from "date-fns/parseISO";

// ✅ Or use dayjs (much smaller)
import dayjs from "dayjs";
dayjs(date).format("YYYY-MM-DD");
```

### Icon Libraries

| Library | Full Size | Per Icon | Recommendation |
|---------|-----------|----------|----------------|
| react-icons | ~50KB+ | ~1KB | Use direct imports |
| lucide-react | ~25KB | ~1KB | Tree-shakeable |
| heroicons | ~30KB | ~1KB | Tree-shakeable |

```tsx
// ❌ react-icons: May bundle all
import { FaHome, FaUser } from "react-icons/fa";

// ✅ react-icons: Direct import
import { FaHome } from "@react-icons/all-files/fa/FaHome";

// ✅ lucide-react: Tree-shakeable by default
import { Home, User } from "lucide-react";
```

### Re-export Barrels

```tsx
// components/index.ts - "Barrel file"
export { Button } from "./Button";
export { Input } from "./Input";
export { Modal } from "./Modal";

// ❌ May import all from barrel
import { Button } from "@/components";

// ✅ Direct import (guaranteed single component)
import { Button } from "@/components/Button";
```

---

## Third-Party Library Optimization

### Heavy Libraries Alternatives

| Heavy Library | Size | Light Alternative | Size |
|---------------|------|-------------------|------|
| moment | 67KB | dayjs | 2KB |
| lodash | 72KB | lodash-es (tree-shake) | ~1KB/fn |
| axios | 14KB | fetch (native) | 0KB |
| uuid | 3KB | crypto.randomUUID() | 0KB |
| classnames | 1KB | clsx | 0.5KB |

### Lazy Load Heavy Libraries

```tsx
// Don't import at top level
async function generatePDF() {
  const { jsPDF } = await import("jspdf");
  const doc = new jsPDF();
  // ...
}

async function parseMarkdown(text) {
  const { marked } = await import("marked");
  return marked.parse(text);
}
```

### CDN for Large Libraries

```tsx
// next.config.js
module.exports = {
  experimental: {
    optimizePackageImports: ["lucide-react", "@heroicons/react"],
  },
};
```

For truly large libraries, consider Script component:

```tsx
import Script from "next/script";

function MapPage() {
  return (
    <>
      <Script 
        src="https://maps.googleapis.com/maps/api/js"
        strategy="lazyOnload"
        onLoad={() => initMap()}
      />
      <div id="map" />
    </>
  );
}
```

---

## Build Configuration

### Next.js Optimizations

```js
// next.config.js
module.exports = {
  // Minification
  swcMinify: true,
  
  // Tree-shake specific packages
  experimental: {
    optimizePackageImports: [
      "lucide-react",
      "@heroicons/react",
      "date-fns",
      "lodash",
    ],
  },
  
  // Analyze large dependencies
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        ...config.resolve.fallback,
        fs: false,
        net: false,
        tls: false,
      };
    }
    return config;
  },
};
```

### Package.json Side Effects

```json
{
  "sideEffects": false
}
```

Or specify files with side effects:

```json
{
  "sideEffects": [
    "*.css",
    "*.scss"
  ]
}
```

### Modern Output

```js
// next.config.js
module.exports = {
  // Use modern JavaScript (smaller bundles)
  experimental: {
    legacyBrowsers: false,
  },
};
```

---

## Metrics & Targets

### Bundle Size Targets

| Page Type | JS Budget | Notes |
|-----------|-----------|-------|
| Landing page | < 100KB | Critical for LCP |
| Web app (initial) | < 200KB | First meaningful paint |
| Full app (loaded) | < 500KB | After lazy loading |

### Before/After Checklist

Before optimization:
- [ ] Run bundle analyzer
- [ ] Identify top 10 largest modules
- [ ] Check bundlephobia for alternatives

After optimization:
- [ ] Run bundle analyzer again
- [ ] Compare before/after sizes
- [ ] Test that features still work
- [ ] Check Lighthouse performance

---

## Quick Wins Summary

| Issue | Fix | Impact |
|-------|-----|--------|
| moment.js | → dayjs | -65KB |
| Full lodash | → lodash-es + tree-shake | -60KB |
| react-icons full | → Direct imports | -40KB |
| Inline source maps | → external | Variable |
| Client-only libs in SSR | → dynamic import with ssr: false | Variable |
| Barrel imports | → Direct file imports | Variable |
