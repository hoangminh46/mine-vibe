# Media Optimization (Images & Fonts)

> Comprehensive guide to optimizing images and fonts for web performance.

---

## Table of Contents

1. [Image Formats](#image-formats)
2. [Next.js Image Component](#nextjs-image-component)
3. [Responsive Images](#responsive-images)
4. [Font Optimization](#font-optimization)
5. [Icons & SVG](#icons--svg)

---

## Image Formats

### Format Comparison

| Format | Best For | Browser Support | Compression |
|--------|----------|-----------------|-------------|
| **WebP** | General use | 97%+ | 25-35% smaller than JPEG |
| **AVIF** | Maximum compression | 85%+ | 50% smaller than JPEG |
| **JPEG** | Photos (fallback) | 100% | Good, lossy |
| **PNG** | Transparency, graphics | 100% | Lossless |
| **SVG** | Icons, logos, illustrations | 100% | Vector, scalable |

### When to Use Each

| Use Case | Recommended Format |
|----------|-------------------|
| Hero images, photos | WebP (AVIF if supported) |
| Product images | WebP with JPEG fallback |
| Logos, icons | SVG |
| Screenshots with text | PNG or WebP |
| Animated images | WebP or optimized GIF |

### Picture Element for Fallbacks

```html
<picture>
  <source srcset="image.avif" type="image/avif" />
  <source srcset="image.webp" type="image/webp" />
  <img src="image.jpg" alt="Description" loading="lazy" />
</picture>
```

---

## Next.js Image Component

### Basic Usage

```tsx
import Image from "next/image";

// Known dimensions
<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
/>

// Fill parent container
<div className="relative h-64">
  <Image
    src="/banner.jpg"
    alt="Banner"
    fill
    style={{ objectFit: "cover" }}
  />
</div>
```

### Priority Loading (LCP)

```tsx
// Use for above-the-fold LCP images
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority  // Disables lazy loading, preloads
/>
```

### Sizes Attribute

```tsx
// Tell browser how wide image will be at different viewports
<Image
  src="/product.jpg"
  alt="Product"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>
```

### Blur Placeholder

```tsx
// Static import (auto blur placeholder)
import heroImage from "../public/hero.jpg";

<Image
  src={heroImage}
  alt="Hero"
  placeholder="blur"
/>

// Dynamic with custom blur
<Image
  src={dynamicUrl}
  alt="Dynamic"
  placeholder="blur"
  blurDataURL={base64Placeholder}
/>
```

### Image Configuration

```js
// next.config.js
module.exports = {
  images: {
    // Remote domains for external images
    remotePatterns: [
      {
        protocol: "https",
        hostname: "images.example.com",
      },
    ],
    
    // Custom device sizes for srcset
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048, 3840],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
    
    // Output format
    formats: ["image/avif", "image/webp"],
  },
};
```

---

## Responsive Images

### srcset and sizes

```html
<!-- Browser chooses best image based on viewport -->
<img
  src="small.jpg"
  srcset="
    small.jpg 400w,
    medium.jpg 800w,
    large.jpg 1200w
  "
  sizes="
    (max-width: 400px) 100vw,
    (max-width: 800px) 50vw,
    33vw
  "
  alt="Responsive image"
  loading="lazy"
/>
```

### Art Direction (Different Images)

```html
<!-- Different crops for different viewports -->
<picture>
  <source 
    media="(max-width: 480px)" 
    srcset="portrait.jpg"
  />
  <source 
    media="(max-width: 1024px)" 
    srcset="square.jpg"
  />
  <img src="landscape.jpg" alt="Art directed" />
</picture>
```

### Lazy Loading Native

```html
<!-- Browser handles lazy loading -->
<img src="photo.jpg" loading="lazy" alt="Photo" />

<!-- Eager for above-fold -->
<img src="hero.jpg" loading="eager" alt="Hero" />
```

### Fetch Priority

```html
<!-- High priority for LCP -->
<img src="hero.jpg" fetchpriority="high" alt="Hero" />

<!-- Low priority for below fold -->
<img src="related.jpg" fetchpriority="low" loading="lazy" alt="Related" />
```

---

## Font Optimization

### Google Fonts with Next.js

```tsx
// app/layout.tsx
import { Inter, Roboto_Mono } from "next/font/google";

const inter = Inter({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-inter",
});

const robotoMono = Roboto_Mono({
  subsets: ["latin"],
  display: "swap",
  variable: "--font-roboto-mono",
});

export default function RootLayout({ children }) {
  return (
    <html className={`${inter.variable} ${robotoMono.variable}`}>
      <body>{children}</body>
    </html>
  );
}
```

```css
/* globals.css */
body {
  font-family: var(--font-inter), system-ui, sans-serif;
}

code {
  font-family: var(--font-roboto-mono), monospace;
}
```

### Local Fonts

```tsx
import localFont from "next/font/local";

const customFont = localFont({
  src: [
    {
      path: "./fonts/CustomFont-Regular.woff2",
      weight: "400",
      style: "normal",
    },
    {
      path: "./fonts/CustomFont-Bold.woff2",
      weight: "700",
      style: "normal",
    },
  ],
  display: "swap",
  variable: "--font-custom",
});
```

### font-display Values

| Value | Behavior |
|-------|----------|
| `swap` | Shows fallback immediately, swaps when loaded |
| `optional` | Uses font only if loaded quickly |
| `fallback` | Short block, then fallback |
| `block` | Invisible text until loaded (FOIT) |

**Recommendation:** Use `swap` for body text, `optional` for decorative fonts.

### Preload Critical Fonts

```html
<head>
  <link
    rel="preload"
    href="/fonts/inter-var.woff2"
    as="font"
    type="font/woff2"
    crossorigin="anonymous"
  />
</head>
```

### Subset Fonts

```tsx
// Only include characters you need
const inter = Inter({
  subsets: ["latin"],  // Not "latin-ext" unless needed
});

// Custom unicode range for icons
const icons = localFont({
  src: "./icons.woff2",
  unicodeRange: "U+E000-E0FF",  // Private use area
});
```

### System Font Stack (Performance First)

```css
/* No external font needed */
body {
  font-family: 
    -apple-system, 
    BlinkMacSystemFont, 
    "Segoe UI", 
    Roboto, 
    Oxygen, 
    Ubuntu, 
    Cantarell, 
    "Open Sans", 
    "Helvetica Neue", 
    sans-serif;
}

/* Monospace */
code {
  font-family: 
    ui-monospace, 
    SFMono-Regular, 
    Menlo, 
    Monaco, 
    Consolas, 
    "Liberation Mono", 
    "Courier New", 
    monospace;
}
```

---

## Icons & SVG

### Inline SVG (Best for LCP)

```tsx
// component
function Logo() {
  return (
    <svg viewBox="0 0 24 24" className="w-8 h-8">
      <path d="M12 2L2 7l10 5 10-5-10-5z" />
    </svg>
  );
}
```

### SVG Sprite

```html
<!-- sprite.svg -->
<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
  <symbol id="icon-home" viewBox="0 0 24 24">
    <path d="M3 12l9-9 9 9" />
  </symbol>
  <symbol id="icon-user" viewBox="0 0 24 24">
    <circle cx="12" cy="8" r="4" />
  </symbol>
</svg>

<!-- Usage -->
<svg class="icon">
  <use href="/sprite.svg#icon-home" />
</svg>
```

### Icon Component Pattern

```tsx
// Icon.tsx
interface IconProps {
  name: string;
  className?: string;
  size?: number;
}

export function Icon({ name, className, size = 24 }: IconProps) {
  return (
    <svg 
      className={className}
      width={size} 
      height={size}
      aria-hidden="true"
    >
      <use href={`/icons.svg#${name}`} />
    </svg>
  );
}

// Usage
<Icon name="home" size={20} />
```

### Icon Libraries Optimization

```tsx
// ❌ Imports entire library
import { FaHome, FaUser } from "react-icons/fa";

// ✅ Individual imports (tree-shaking)
import { FaHome } from "react-icons/fa/FaHome";

// Or use lucide-react (smaller, tree-shakeable)
import { Home, User } from "lucide-react";
```

---

## Performance Checklist

### Images

- [ ] Use WebP/AVIF with fallbacks
- [ ] Set explicit width/height (prevents CLS)
- [ ] Use `priority` for LCP images
- [ ] Use `loading="lazy"` for below-fold
- [ ] Use `sizes` attribute for responsive
- [ ] Compress images (Squoosh, ImageOptim)

### Fonts

- [ ] Use `next/font` or preload fonts
- [ ] Use `font-display: swap`
- [ ] Subset fonts (latin only if possible)
- [ ] Consider system fonts for body text
- [ ] Limit font weights/styles

### Icons

- [ ] Use inline SVG for critical icons
- [ ] Use SVG sprite for many icons
- [ ] Tree-shake icon libraries
- [ ] Add `aria-hidden="true"` for decorative icons
