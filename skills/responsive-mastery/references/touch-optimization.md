# 👆 Touch Optimization Guide

## Table of Contents
1. [Touch Target Sizes](#touch-target-sizes)
2. [Touch vs Click Events](#touch-vs-click-events)
3. [Hover States on Touch](#hover-states-on-touch)
4. [Gesture Handling](#gesture-handling)
5. [Performance Considerations](#performance-considerations)

---

## Touch Target Sizes

### Minimum Size Guidelines
- **Apple HIG**: 44x44 points (44x44 CSS pixels)
- **Material Design**: 48x48 dp
- **WCAG 2.1 AAA**: 44x44 CSS pixels

### Implementation
```css
/* Ensure minimum touch target */
button,
a,
input[type="checkbox"],
input[type="radio"],
[role="button"] {
  min-height: 44px;
  min-width: 44px;
}

/* Padding approach for text links */
a {
  padding: 8px 12px;
  margin: -8px -12px; /* Compensate visual alignment */
}

/* Icon buttons */
.icon-button {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44px;
  height: 44px;
  padding: 10px;
}

.icon-button svg {
  width: 24px;
  height: 24px;
}
```

### Spacing Between Targets
```css
/* Adequate spacing to prevent mis-taps */
.button-group {
  display: flex;
  gap: 8px; /* Minimum 8px between targets */
}

.nav-list {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.nav-list a {
  padding: 12px 16px;
}
```

### Thumb Zone Consideration
```css
/* Place important actions in easy-to-reach areas */
.bottom-actions {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 16px;
  padding-bottom: calc(16px + env(safe-area-inset-bottom));
}

/* Primary action should be in thumb reach */
.primary-action {
  position: fixed;
  bottom: 80px;
  right: 16px;
}
```

---

## Touch vs Click Events

### Event Handling
```javascript
// ✅ Use click for compatibility (works for both)
button.addEventListener('click', handleAction);

// ⚠️ Touch-specific when needed
element.addEventListener('touchstart', handleTouchStart, { passive: true });
element.addEventListener('touchend', handleTouchEnd);
element.addEventListener('touchmove', handleTouchMove, { passive: true });
```

### Pointer Events (Modern Approach)
```javascript
// ✅ Best: Works for mouse, touch, and pen
element.addEventListener('pointerdown', handleStart);
element.addEventListener('pointerup', handleEnd);
element.addEventListener('pointermove', handleMove);
element.addEventListener('pointercancel', handleCancel);

// Pointer event properties
function handleStart(e) {
  console.log(e.pointerType); // "mouse", "touch", "pen"
  console.log(e.pressure); // 0-1 for touch/pen
  console.log(e.isPrimary); // Primary pointer
}
```

### Passive Event Listeners
```javascript
// ✅ Passive listeners for scroll performance
element.addEventListener('touchstart', handler, { passive: true });
element.addEventListener('touchmove', handler, { passive: true });
element.addEventListener('wheel', handler, { passive: true });

// ⚠️ Non-passive only when preventDefault needed
element.addEventListener('touchmove', (e) => {
  if (shouldPrevent) e.preventDefault();
}, { passive: false });
```

### Detecting Touch Support
```javascript
// Check for touch support
const isTouchDevice = 'ontouchstart' in window || 
  navigator.maxTouchPoints > 0;

// ✅ Better: Feature detection in CSS
@media (hover: hover) and (pointer: fine) {
  /* Mouse/trackpad users */
}

@media (hover: none) and (pointer: coarse) {
  /* Touch users */
}
```

---

## Hover States on Touch

### The Problem
Hover states can "stick" on touch devices after tapping.

### Solution 1: Media Queries
```css
/* Only apply hover on devices that support it */
@media (hover: hover) {
  .button:hover {
    background-color: var(--hover-color);
    transform: translateY(-2px);
  }
}

/* Touch devices get active state instead */
@media (hover: none) {
  .button:active {
    background-color: var(--active-color);
    transform: scale(0.98);
  }
}
```

### Solution 2: Combined Approach
```css
/* Base styles */
.button {
  background-color: var(--primary);
  transition: all 0.2s ease;
}

/* Hover for mouse users */
@media (hover: hover) and (pointer: fine) {
  .button:hover {
    background-color: var(--primary-hover);
  }
}

/* Active state for all (touch feedback) */
.button:active {
  background-color: var(--primary-active);
  transform: scale(0.98);
}

/* Focus for keyboard users */
.button:focus-visible {
  outline: 2px solid var(--focus-ring);
  outline-offset: 2px;
}
```

### Solution 3: JavaScript Enhancement
```javascript
// Add touch class to html
if ('ontouchstart' in window) {
  document.documentElement.classList.add('touch-device');
}
```

```css
/* CSS for touch devices */
.touch-device .button:hover {
  /* Disable hover effects */
  background-color: var(--primary);
}

.touch-device .button:active {
  background-color: var(--primary-active);
}
```

---

## Gesture Handling

### Basic Swipe Detection
```javascript
let touchStartX = 0;
let touchStartY = 0;

element.addEventListener('touchstart', (e) => {
  touchStartX = e.touches[0].clientX;
  touchStartY = e.touches[0].clientY;
}, { passive: true });

element.addEventListener('touchend', (e) => {
  const touchEndX = e.changedTouches[0].clientX;
  const touchEndY = e.changedTouches[0].clientY;
  
  const diffX = touchEndX - touchStartX;
  const diffY = touchEndY - touchStartY;
  
  const minSwipeDistance = 50;
  
  // Horizontal swipe
  if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > minSwipeDistance) {
    if (diffX > 0) {
      handleSwipeRight();
    } else {
      handleSwipeLeft();
    }
  }
  
  // Vertical swipe
  if (Math.abs(diffY) > Math.abs(diffX) && Math.abs(diffY) > minSwipeDistance) {
    if (diffY > 0) {
      handleSwipeDown();
    } else {
      handleSwipeUp();
    }
  }
});
```

### Pull to Refresh Pattern
```javascript
let startY = 0;
let isPulling = false;

container.addEventListener('touchstart', (e) => {
  if (container.scrollTop === 0) {
    startY = e.touches[0].clientY;
    isPulling = true;
  }
});

container.addEventListener('touchmove', (e) => {
  if (!isPulling) return;
  
  const currentY = e.touches[0].clientY;
  const pullDistance = currentY - startY;
  
  if (pullDistance > 0 && pullDistance < 150) {
    indicator.style.transform = `translateY(${pullDistance}px)`;
    indicator.style.opacity = pullDistance / 100;
  }
});

container.addEventListener('touchend', () => {
  if (isPulling && /* pulled enough */) {
    refreshContent();
  }
  resetIndicator();
  isPulling = false;
});
```

### CSS Touch Action
```css
/* Control touch behavior */

/* Allow only horizontal panning */
.carousel {
  touch-action: pan-x;
  overflow-x: scroll;
  scroll-snap-type: x mandatory;
}

/* Allow only vertical scrolling */
.vertical-list {
  touch-action: pan-y;
}

/* Disable double-tap zoom */
.button {
  touch-action: manipulation;
}

/* Disable all gestures (custom handling) */
.custom-gesture-area {
  touch-action: none;
}
```

### Scroll Snap for Carousels
```css
.carousel {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scroll-behavior: smooth;
  -webkit-overflow-scrolling: touch;
}

.carousel-item {
  flex: 0 0 100%;
  scroll-snap-align: start;
}

/* Hide scrollbar but keep functionality */
.carousel {
  scrollbar-width: none;
  -ms-overflow-style: none;
}

.carousel::-webkit-scrollbar {
  display: none;
}
```

---

## Performance Considerations

### Tap Delay Removal
```html
<!-- Modern browsers: no delay by default with viewport meta -->
<meta name="viewport" content="width=device-width, initial-scale=1">
```

```css
/* Ensure no tap delay */
html {
  touch-action: manipulation;
}
```

### GPU Acceleration
```css
/* Promote to GPU layer for smooth interactions */
.animated-element {
  will-change: transform;
  transform: translateZ(0);
}

/* Remove after animation completes */
.animated-element.idle {
  will-change: auto;
}
```

### Debouncing Touch Events
```javascript
// Throttle expensive operations
let ticking = false;

element.addEventListener('touchmove', (e) => {
  if (!ticking) {
    requestAnimationFrame(() => {
      handleMove(e);
      ticking = false;
    });
    ticking = true;
  }
}, { passive: true });
```

### Reduce Motion
```css
/* Respect user preference */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

```javascript
// JavaScript detection
const prefersReducedMotion = window.matchMedia(
  '(prefers-reduced-motion: reduce)'
).matches;

if (!prefersReducedMotion) {
  enableAnimations();
}
```

---

## Summary Checklist

- [ ] All touch targets are at least 44x44 pixels
- [ ] Minimum 8px spacing between touch targets
- [ ] Use pointer events for unified input handling
- [ ] Add passive: true to scroll-related listeners
- [ ] Handle hover states with @media (hover: hover)
- [ ] Implement :active state for touch feedback
- [ ] Use touch-action CSS for gesture control
- [ ] Respect prefers-reduced-motion
- [ ] Test on real touch devices
