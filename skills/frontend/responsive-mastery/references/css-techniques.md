# 🎨 Modern CSS Techniques for Responsive Design

## Table of Contents
1. [Fluid Typography](#fluid-typography)
2. [CSS Functions (clamp, min, max)](#css-functions)
3. [Container Queries](#container-queries)
4. [Grid Patterns](#grid-patterns)
5. [Flexbox Patterns](#flexbox-patterns)

---

## Fluid Typography

### Basic Fluid Typography
```css
/* Typography scale với clamp() */
:root {
  --text-xs: clamp(0.75rem, 1.5vw, 0.875rem);
  --text-sm: clamp(0.875rem, 2vw, 1rem);
  --text-base: clamp(1rem, 2.5vw, 1.125rem);
  --text-lg: clamp(1.125rem, 3vw, 1.25rem);
  --text-xl: clamp(1.25rem, 3.5vw, 1.5rem);
  --text-2xl: clamp(1.5rem, 4vw, 2rem);
  --text-3xl: clamp(2rem, 5vw, 3rem);
  --text-4xl: clamp(2.5rem, 6vw, 4rem);
}

h1 { font-size: var(--text-4xl); }
h2 { font-size: var(--text-3xl); }
h3 { font-size: var(--text-2xl); }
p { font-size: var(--text-base); }
```

### Fluid Spacing Scale
```css
:root {
  --space-xs: clamp(0.25rem, 1vw, 0.5rem);
  --space-sm: clamp(0.5rem, 2vw, 1rem);
  --space-md: clamp(1rem, 3vw, 1.5rem);
  --space-lg: clamp(1.5rem, 4vw, 2rem);
  --space-xl: clamp(2rem, 5vw, 3rem);
  --space-2xl: clamp(3rem, 8vw, 6rem);
}

.section {
  padding-block: var(--space-xl);
  padding-inline: var(--space-md);
}

.card {
  padding: var(--space-md);
  gap: var(--space-sm);
}
```

### Line Height & Measure
```css
/* Optimal reading experience */
p {
  font-size: clamp(1rem, 2.5vw, 1.25rem);
  line-height: 1.6;
  max-width: 65ch; /* Optimal line length */
}

/* Tighter line-height for headings */
h1, h2, h3 {
  line-height: 1.2;
}
```

---

## CSS Functions

### clamp() - Fluid Values
```css
/* clamp(minimum, preferred, maximum) */

/* Width */
.container {
  width: clamp(320px, 90vw, 1200px);
}

/* Font size */
h1 {
  font-size: clamp(2rem, 5vw + 1rem, 4rem);
}

/* Padding */
.section {
  padding: clamp(1rem, 5vw, 4rem);
}

/* Gap */
.grid {
  gap: clamp(1rem, 3vw, 2rem);
}
```

### min() - Maximum Constraint
```css
/* min() returns smaller value */

/* Max-width without media query */
.container {
  width: min(90vw, 1200px);
  /* Same as: max-width: 1200px; width: 90vw; */
}

/* Responsive padding */
.card {
  padding: min(5vw, 2rem);
}

/* Image that doesn't exceed container */
img {
  width: min(100%, 600px);
}
```

### max() - Minimum Constraint
```css
/* max() returns larger value */

/* Min-width */
.sidebar {
  width: max(200px, 20vw);
}

/* Safe area with minimum padding */
.header {
  padding-left: max(1rem, env(safe-area-inset-left));
}

/* Ensure readable font size */
p {
  font-size: max(16px, 1rem);
}
```

### Combining Functions
```css
/* Responsive container with constraints */
.container {
  width: min(100% - 2rem, 1200px);
  margin-inline: auto;
}

/* Fluid but constrained spacing */
.section {
  padding: clamp(1rem, max(3vw, 2rem), 4rem);
}

/* Complex responsive value */
.hero {
  height: min(max(400px, 50vh), 800px);
}
```

---

## Container Queries

### Basic Setup
```css
/* 1. Define container */
.card-wrapper {
  container-type: inline-size;
  container-name: card;
}

/* Shorthand */
.card-wrapper {
  container: card / inline-size;
}

/* 2. Query the container */
@container card (min-width: 400px) {
  .card {
    display: grid;
    grid-template-columns: 150px 1fr;
  }
}

@container card (min-width: 600px) {
  .card {
    grid-template-columns: 200px 1fr auto;
  }
}
```

### Container Query Units
```css
/* cqw = 1% of container width */
/* cqh = 1% of container height */
/* cqi = 1% of container inline size */
/* cqb = 1% of container block size */

.card-wrapper {
  container-type: inline-size;
}

.card-title {
  font-size: clamp(1rem, 5cqi, 2rem);
}

.card-image {
  width: 30cqi;
}
```

### Real-World Example
```css
/* Reusable card component */
.card-container {
  container: card / inline-size;
}

.card {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.card-image {
  width: 100%;
  aspect-ratio: 16/9;
  object-fit: cover;
}

/* Horizontal layout when container is wide enough */
@container card (min-width: 500px) {
  .card {
    flex-direction: row;
  }
  
  .card-image {
    width: 40%;
    aspect-ratio: 1;
  }
  
  .card-content {
    flex: 1;
  }
}

/* Show extra info on large containers */
@container card (min-width: 700px) {
  .card-meta {
    display: flex;
  }
}
```

---

## Grid Patterns

### Auto-Fit Grid
```css
/* Cards that auto-adjust */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

/* With max columns */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(280px, 100%), 1fr));
  gap: 1.5rem;
}
```

### RAM Pattern (Repeat, Auto, Minmax)
```css
/* Responsive grid without media queries */
.grid {
  display: grid;
  grid-template-columns: repeat(
    auto-fit,
    minmax(min(100%, 300px), 1fr)
  );
  gap: 1rem;
}
```

### Sidebar Layout
```css
/* Sidebar that collapses on mobile */
.sidebar-layout {
  display: grid;
  grid-template-columns: 1fr;
  gap: 2rem;
}

@media (min-width: 768px) {
  .sidebar-layout {
    grid-template-columns: minmax(200px, 25%) 1fr;
  }
}

/* Or with container query */
.page-container {
  container-type: inline-size;
}

@container (min-width: 768px) {
  .sidebar-layout {
    grid-template-columns: minmax(200px, 25%) 1fr;
  }
}
```

### Holy Grail Layout
```css
.page {
  display: grid;
  grid-template-rows: auto 1fr auto;
  grid-template-areas:
    "header"
    "main"
    "footer";
  min-height: 100dvh;
}

@media (min-width: 768px) {
  .page {
    grid-template-columns: 200px 1fr 200px;
    grid-template-areas:
      "header header header"
      "nav main aside"
      "footer footer footer";
  }
}

.header { grid-area: header; }
.nav { grid-area: nav; }
.main { grid-area: main; }
.aside { grid-area: aside; }
.footer { grid-area: footer; }
```

### Masonry-like Grid
```css
/* CSS Grid masonry (experimental) */
.masonry {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  grid-template-rows: masonry; /* Not widely supported yet */
  gap: 1rem;
}

/* Fallback with columns */
.masonry-fallback {
  columns: 3 250px;
  column-gap: 1rem;
}

.masonry-fallback > * {
  break-inside: avoid;
  margin-bottom: 1rem;
}
```

---

## Flexbox Patterns

### Wrap with Minimum Width
```css
.flex-wrap {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

.flex-wrap > * {
  flex: 1 1 300px; /* grow, shrink, basis */
}
```

### Navbar Pattern
```css
.navbar {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.nav-links {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem 1rem;
}
```

### Card Footer Pattern
```css
.card {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.card-content {
  flex: 1; /* Takes available space */
}

.card-footer {
  margin-top: auto; /* Pushed to bottom */
}
```

### Responsive Direction
```css
.flex-responsive {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

@media (min-width: 768px) {
  .flex-responsive {
    flex-direction: row;
  }
}
```

---

## Summary

| Technique | Best For |
|-----------|----------|
| `clamp()` | Fluid typography, spacing |
| `min()` | Maximum constraints |
| `max()` | Minimum constraints, safe areas |
| Container Queries | Reusable components |
| CSS Grid `auto-fit` | Responsive grids without media queries |
| Flexbox `flex-wrap` | Flowing layouts |
