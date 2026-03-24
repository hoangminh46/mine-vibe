---
name: responsive-mastery
description: Complete guide to responsive web design with mobile-first approach, modern CSS techniques, and cross-device optimization. Use when (1) building responsive layouts with CSS Grid/Flexbox, (2) implementing fluid typography with clamp(), (3) using container queries for component-based responsiveness, (4) fixing mobile-specific issues like 100vh problem or safe area insets, (5) optimizing touch interactions, (6) handling viewport units (dvh, svh, lvh), or (7) testing across multiple devices.
---

# 📱 Responsive Mastery

Skill này giúp xây dựng giao diện responsive hoàn hảo trên mọi thiết bị với **Mobile-First approach**.

## 📚 Quick Navigation

| Topic | Reference File | Use When |
|-------|---------------|----------|
| CSS Techniques | [references/css-techniques.md](references/css-techniques.md) | Fluid layouts, clamp(), container queries |
| Mobile Issues | [references/mobile-issues.md](references/mobile-issues.md) | 100vh problem, safe areas, orientation |
| Touch Optimization | [references/touch-optimization.md](references/touch-optimization.md) | Touch targets, gestures, hover states |

---

## 🎯 Core Principles

### 1. Mobile-First Design
Thiết kế cho mobile trước, rồi progressive enhancement cho màn hình lớn.

```css
/* ✅ Mobile-first: Base styles cho mobile */
.container {
  padding: 1rem;
  display: flex;
  flex-direction: column;
}

/* Enhancement cho tablet */
@media (min-width: 768px) {
  .container {
    flex-direction: row;
    padding: 2rem;
  }
}

/* Enhancement cho desktop */
@media (min-width: 1024px) {
  .container {
    max-width: 1200px;
    margin: 0 auto;
  }
}
```

### 2. Content-First Breakpoints
Đặt breakpoints dựa trên content, không phải device cố định.

```css
/* ❌ Device-based (fragile) */
@media (min-width: 768px) { } /* iPad? */
@media (min-width: 1024px) { } /* iPad Pro? Desktop? */

/* ✅ Content-based (resilient) */
/* Khi content cần 2 columns */
@media (min-width: 40em) { }
/* Khi sidebar có đủ không gian */
@media (min-width: 60em) { }
```

### 3. Fluid Everything
Sử dụng relative units thay vì fixed pixels.

---

## ⚡ Quick Reference

### Breakpoint System
```css
:root {
  /* Recommended breakpoints */
  --bp-sm: 480px;   /* Mobile landscape */
  --bp-md: 768px;   /* Tablet */
  --bp-lg: 1024px;  /* Desktop */
  --bp-xl: 1280px;  /* Large desktop */
  --bp-2xl: 1536px; /* Extra large */
}

/* Using min-width (mobile-first) */
@media (min-width: 768px) { }

/* Prefer custom properties with container queries */
@container (min-width: 400px) { }
```

### Fluid Typography with clamp()
```css
/* clamp(minimum, preferred, maximum) */
h1 {
  /* 32px at min, scales with viewport, max 64px */
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
}

p {
  /* Readable text that scales nicely */
  font-size: clamp(1rem, 2.5vw, 1.25rem);
  line-height: 1.6;
}

/* Fluid spacing */
.section {
  padding: clamp(1rem, 5vw, 4rem);
  gap: clamp(1rem, 3vw, 2rem);
}
```

### Container Queries
```css
/* Define container */
.card-container {
  container-type: inline-size;
  container-name: card;
}

/* Style based on container size, not viewport */
@container card (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 200px 1fr;
  }
}

@container card (min-width: 600px) {
  .card {
    grid-template-columns: 300px 1fr 100px;
  }
}
```

### Modern Viewport Units
```css
/* ❌ 100vh problem on iOS Safari */
.hero {
  height: 100vh; /* May be covered by browser UI */
}

/* ✅ Dynamic viewport height */
.hero {
  height: 100dvh; /* Adjusts when browser UI appears/disappears */
}

/* ✅ Small viewport (always visible) */
.full-page {
  min-height: 100svh; /* Safe, never covered by UI */
}

/* ✅ Large viewport (maximum space) */
.splash {
  height: 100lvh; /* Uses max available when UI hidden */
}
```

### Flexible Images
```css
/* Responsive images */
img {
  max-width: 100%;
  height: auto;
  display: block;
}

/* Maintain aspect ratio */
.video-container {
  aspect-ratio: 16 / 9;
  width: 100%;
}

/* Object-fit for cropping */
.cover-image {
  width: 100%;
  height: 300px;
  object-fit: cover;
  object-position: center;
}
```

---

## 📐 Layout Patterns

### Holy Grail Layout
```css
.layout {
  display: grid;
  grid-template-areas:
    "header"
    "main"
    "sidebar"
    "footer";
  min-height: 100dvh;
}

@media (min-width: 768px) {
  .layout {
    grid-template-areas:
      "header header"
      "sidebar main"
      "footer footer";
    grid-template-columns: 250px 1fr;
  }
}
```

### Card Grid (Auto-fit)
```css
/* Cards that auto-adjust based on space */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: clamp(1rem, 3vw, 2rem);
}
```

### Sidebar Layout
```css
.sidebar-layout {
  display: grid;
  grid-template-columns: 1fr;
}

@media (min-width: 768px) {
  .sidebar-layout {
    grid-template-columns: minmax(200px, 300px) 1fr;
  }
}
```

---

## 📱 Mobile Essentials

### Touch Target Sizes
```css
/* Minimum 44x44px for touch targets */
button, 
a,
[role="button"] {
  min-height: 44px;
  min-width: 44px;
  padding: 12px 16px;
}

/* Adequate spacing between targets */
.nav-list {
  gap: 8px;
}
```

### Safe Area Insets (Notch)
```css
/* Support for notched devices */
.header {
  padding-top: env(safe-area-inset-top);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

.bottom-nav {
  padding-bottom: env(safe-area-inset-bottom);
}

/* With fallback */
.container {
  padding-left: max(1rem, env(safe-area-inset-left));
  padding-right: max(1rem, env(safe-area-inset-right));
}
```

### Viewport Meta Tag
```html
<!-- Essential for responsive design -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Prevent zoom on input focus (iOS) -->
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
```

---

## 🎨 CSS Features Cheat Sheet

| Feature | Syntax | Use Case |
|---------|--------|----------|
| `clamp()` | `clamp(min, preferred, max)` | Fluid typography, spacing |
| `min()` | `min(a, b)` | Max-width without media query |
| `max()` | `max(a, b)` | Min-width, safe area fallbacks |
| `minmax()` | `minmax(min, max)` | Grid column sizing |
| `auto-fit` | `repeat(auto-fit, minmax())` | Auto-adjusting grids |
| `auto-fill` | `repeat(auto-fill, minmax())` | Keep empty tracks |
| `aspect-ratio` | `aspect-ratio: 16/9` | Maintain proportions |
| `object-fit` | `cover`, `contain`, `fill` | Image cropping |
| Container Query | `@container (min-width)` | Component-based responsive |

---

## ✅ Responsive Checklist

### Before Development
- [ ] Define content-based breakpoints
- [ ] Create fluid typography scale
- [ ] Plan mobile navigation pattern
- [ ] Identify touch-heavy interactions

### CSS Implementation
- [ ] Use mobile-first media queries
- [ ] Implement fluid typography with clamp()
- [ ] Use container queries for reusable components
- [ ] Handle safe area insets
- [ ] Set proper touch target sizes (44px min)

### Testing
- [ ] Test on real devices (not just DevTools)
- [ ] Check landscape orientation
- [ ] Test with different text sizes (accessibility)
- [ ] Verify touch interactions work smoothly
- [ ] Check performance on slow networks

---

## 📖 Deep Dive References

1. **[css-techniques.md](references/css-techniques.md)** - clamp(), container queries, grid patterns
2. **[mobile-issues.md](references/mobile-issues.md)** - 100vh problem, viewport units, orientation
3. **[touch-optimization.md](references/touch-optimization.md)** - Touch targets, gestures, hover states
