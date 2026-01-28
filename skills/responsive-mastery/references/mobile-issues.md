# 📱 Mobile-Specific Issues & Solutions

## Table of Contents
1. [100vh Problem](#100vh-problem)
2. [Viewport Units (dvh, svh, lvh)](#viewport-units)
3. [Safe Area Insets](#safe-area-insets)
4. [Orientation Changes](#orientation-changes)
5. [Mobile Browser Quirks](#mobile-browser-quirks)

---

## 100vh Problem

### The Issue
On mobile browsers, `100vh` is calculated based on the **maximum** viewport height (when browser UI is hidden), causing content to be cut off when the address bar is visible.

```css
/* ❌ Problem: Content cut off on mobile */
.hero {
  height: 100vh;
}
```

### Solutions

#### 1. Use Dynamic Viewport Units (Best)
```css
/* ✅ Adjusts when browser UI appears/disappears */
.hero {
  height: 100dvh;
}
```

#### 2. Use Small Viewport Height (Safe)
```css
/* ✅ Always fits in visible area */
.hero {
  min-height: 100svh;
}
```

#### 3. JavaScript Fallback (Legacy)
```javascript
// For browsers without dvh support
const setVH = () => {
  const vh = window.innerHeight * 0.01;
  document.documentElement.style.setProperty('--vh', `${vh}px`);
};

setVH();
window.addEventListener('resize', setVH);
```

```css
.hero {
  height: 100vh; /* Fallback */
  height: calc(var(--vh, 1vh) * 100);
}
```

#### 4. CSS Fallback Stack
```css
.hero {
  height: 100vh; /* Fallback for old browsers */
  height: 100svh; /* Safe viewport height */
}
```

---

## Viewport Units

### Comparison

| Unit | Description | Use Case |
|------|-------------|----------|
| `vh` | 1% of initial viewport height | Legacy, desktop |
| `dvh` | 1% of dynamic viewport height | Full-screen that adjusts |
| `svh` | 1% of small viewport (UI visible) | Safe full-height layouts |
| `lvh` | 1% of large viewport (UI hidden) | Maximum available space |

### Width Equivalents
- `vw` → `dvw`, `svw`, `lvw`

### Block/Inline Variants
- `vb` / `dvb` / `svb` / `lvb` - Block direction
- `vi` / `dvi` / `svi` / `lvi` - Inline direction

### Practical Usage
```css
/* Hero that adapts to browser UI */
.hero {
  min-height: 100dvh;
  display: flex;
  align-items: center;
}

/* Bottom navigation - always visible */
.bottom-nav {
  position: fixed;
  bottom: 0;
  height: auto;
  padding-bottom: env(safe-area-inset-bottom);
}

/* Full page app */
.app {
  height: 100svh; /* Safe, never covered */
  display: flex;
  flex-direction: column;
}

/* Splash screen using max space */
.splash {
  height: 100lvh;
}
```

### Browser Support Check
```css
/* Feature detection */
@supports (height: 100dvh) {
  .hero {
    height: 100dvh;
  }
}

@supports not (height: 100dvh) {
  .hero {
    height: 100vh;
  }
}
```

---

## Safe Area Insets

### The Problem
Devices with notches or rounded corners can obscure content.

### Solution: env() Function
```css
/* Basic safe area padding */
.container {
  padding-top: env(safe-area-inset-top);
  padding-right: env(safe-area-inset-right);
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
}

/* With fallback values */
.container {
  padding-top: env(safe-area-inset-top, 0px);
  padding-left: env(safe-area-inset-left, 1rem);
}
```

### Combined with max()
```css
/* Ensure minimum padding + safe area */
.header {
  padding-top: max(1rem, env(safe-area-inset-top));
  padding-left: max(1rem, env(safe-area-inset-left));
  padding-right: max(1rem, env(safe-area-inset-right));
}
```

### Fixed Elements
```css
/* Fixed header */
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  padding-top: env(safe-area-inset-top);
}

/* Fixed bottom navigation */
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding-bottom: env(safe-area-inset-bottom);
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}

/* Adjust body to not overlap fixed elements */
body {
  padding-top: calc(60px + env(safe-area-inset-top));
  padding-bottom: calc(80px + env(safe-area-inset-bottom));
}
```

### Viewport Meta Tag
```html
<!-- Enable safe area insets -->
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
```

---

## Orientation Changes

### Detect Orientation with CSS
```css
/* Portrait mode */
@media (orientation: portrait) {
  .gallery {
    grid-template-columns: 1fr;
  }
}

/* Landscape mode */
@media (orientation: landscape) {
  .gallery {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

### Combine with Size
```css
/* Mobile landscape (specific) */
@media (orientation: landscape) and (max-height: 500px) {
  .hero {
    min-height: auto;
    padding: 2rem;
  }
  
  .hero-title {
    font-size: 1.5rem;
  }
}
```

### Aspect Ratio Queries
```css
/* Wide screens */
@media (min-aspect-ratio: 16/9) {
  .video-section {
    height: 100vh;
  }
}

/* Tall screens */
@media (max-aspect-ratio: 9/16) {
  .sidebar {
    display: none;
  }
}
```

### JavaScript Orientation Handling
```javascript
// Detect orientation change
window.addEventListener('orientationchange', () => {
  // Wait for resize to complete
  setTimeout(() => {
    // Recalculate layouts if needed
    recalculateLayout();
  }, 100);
});

// Or use matchMedia
const landscape = window.matchMedia('(orientation: landscape)');
landscape.addEventListener('change', (e) => {
  if (e.matches) {
    // Landscape
  } else {
    // Portrait
  }
});
```

---

## Mobile Browser Quirks

### iOS Safari Issues

#### Rubber Band Scrolling
```css
/* Prevent overscroll on specific elements */
.modal {
  overscroll-behavior: contain;
}

/* Prevent entire page overscroll */
html, body {
  overscroll-behavior: none;
}
```

#### Input Zoom Prevention
```css
/* Prevent zoom on input focus (16px minimum) */
input, select, textarea {
  font-size: 16px; /* iOS won't zoom if >= 16px */
}

/* Or use viewport meta (may hurt accessibility) */
/* <meta name="viewport" content="..., maximum-scale=1"> */
```

#### Position Fixed Issues
```css
/* Fixed element jumping on iOS */
.fixed-element {
  position: fixed;
  /* Use transform for GPU acceleration */
  transform: translateZ(0);
  -webkit-transform: translateZ(0);
}
```

### Android Chrome Issues

#### URL Bar and 100vh
```css
/* Same dvh solution works */
.full-height {
  height: 100dvh;
}
```

#### Tap Highlight
```css
/* Remove tap highlight */
* {
  -webkit-tap-highlight-color: transparent;
}

/* Or customize */
a, button {
  -webkit-tap-highlight-color: rgba(0, 0, 0, 0.1);
}
```

### Cross-Browser Fixes

#### Smooth Scrolling
```css
/* Enable smooth scrolling */
html {
  scroll-behavior: smooth;
}

/* Respect reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  html {
    scroll-behavior: auto;
  }
}
```

#### Touch Action
```css
/* Prevent horizontal scroll on swipe elements */
.horizontal-scroll {
  touch-action: pan-x;
}

/* Disable pinch zoom on specific element */
.no-pinch {
  touch-action: pan-x pan-y;
}

/* Allow all gestures */
.interactive {
  touch-action: manipulation;
}
```

#### Momentum Scrolling (iOS)
```css
.scrollable {
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}
```

---

## Summary Checklist

- [ ] Use `100dvh` or `100svh` instead of `100vh`
- [ ] Add viewport-fit=cover meta tag
- [ ] Handle safe-area-inset for notched devices
- [ ] Test both portrait and landscape orientations
- [ ] Set font-size >= 16px on inputs (iOS zoom)
- [ ] Use overscroll-behavior for modals
- [ ] Respect prefers-reduced-motion
- [ ] Test on real devices, not just emulators
