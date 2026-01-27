---
name: framer-motion-magic
description: Framer Motion animation patterns and best practices for React. Page transitions, modal animations, gesture interactions, scroll-triggered effects, performance optimization, and accessibility. Use when creating animations, transitions, interactive UI components, micro-interactions, or implementing motion design in React/Next.js applications.
---

# Framer Motion Magic ✨

> Production-ready animation patterns for stunning React UIs.

---

## 1. Core Concepts

### motion Components

| Element | Usage |
|---------|-------|
| `motion.div` | Animated div container |
| `motion.button` | Interactive button |
| `motion.svg` | SVG animations |
| `motion.create(Component)` | Wrap custom components |

### Animation Properties

| Prop | Purpose |
|------|---------|
| `initial` | Starting state (string or object) |
| `animate` | Target state to animate to |
| `exit` | State when unmounting (needs AnimatePresence) |
| `transition` | Timing, easing, spring config |
| `variants` | Named animation states |

### Transition Types

| Type | When to Use |
|------|-------------|
| `type: "spring"` | Natural, bouncy feel (default) |
| `type: "tween"` | Precise timing control |
| `type: "inertia"` | Momentum-based (drag) |

```tsx
// Spring (natural motion)
transition={{ type: "spring", stiffness: 300, damping: 20 }}

// Tween (precise)
transition={{ type: "tween", duration: 0.3, ease: "easeInOut" }}
```

---

## 2. Essential Patterns

### Fade In

```tsx
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.3 }}
>
  Content
</motion.div>
```

### Slide Up with Fade

```tsx
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.4, ease: "easeOut" }}
>
  Content
</motion.div>
```

### Scale on Hover

```tsx
<motion.button
  whileHover={{ scale: 1.05 }}
  whileTap={{ scale: 0.95 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
>
  Click me
</motion.button>
```

### Stagger Children

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: { staggerChildren: 0.1 }
  }
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { opacity: 1, y: 0 }
};

<motion.ul variants={containerVariants} initial="hidden" animate="visible">
  {items.map(item => (
    <motion.li key={item.id} variants={itemVariants}>
      {item.name}
    </motion.li>
  ))}
</motion.ul>
```

---

## 3. AnimatePresence (Mount/Unmount)

### Basic Exit Animation

```tsx
import { AnimatePresence, motion } from "framer-motion";

<AnimatePresence>
  {isVisible && (
    <motion.div
      key="modal"
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
    >
      Modal content
    </motion.div>
  )}
</AnimatePresence>
```

### Mode Options

| Mode | Behavior |
|------|----------|
| `mode="sync"` | Enter/exit simultaneously (default) |
| `mode="wait"` | Wait for exit before enter |
| `mode="popLayout"` | Pop exiting element from layout flow |

### Page Transitions (Next.js)

```tsx
// In _app.tsx or layout.tsx
<AnimatePresence mode="wait" initial={false}>
  <motion.div
    key={router.pathname}
    initial={{ opacity: 0, x: 20 }}
    animate={{ opacity: 1, x: 0 }}
    exit={{ opacity: 0, x: -20 }}
    transition={{ duration: 0.3 }}
  >
    <Component {...pageProps} />
  </motion.div>
</AnimatePresence>
```

---

## 4. Gesture Animations

### Interactive Props

| Prop | Trigger |
|------|---------|
| `whileHover` | Mouse enter |
| `whileTap` | Mouse down / touch |
| `whileFocus` | Element focused |
| `whileDrag` | During drag |
| `whileInView` | Element in viewport |

### Drag

```tsx
<motion.div
  drag
  dragConstraints={{ left: -100, right: 100, top: -50, bottom: 50 }}
  dragElastic={0.2}
  whileDrag={{ scale: 1.1 }}
/>
```

### Drag with useDragControls

```tsx
const controls = useDragControls();

<div onPointerDown={(e) => controls.start(e)}>
  Drag handle
</div>
<motion.div drag="x" dragControls={controls}>
  Draggable content
</motion.div>
```

---

## 5. Scroll Animations

### whileInView (Simple)

```tsx
<motion.div
  initial={{ opacity: 0, y: 50 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: "-100px" }}
  transition={{ duration: 0.5 }}
>
  Animates when scrolled into view
</motion.div>
```

### useScroll Hook

```tsx
const { scrollYProgress } = useScroll();

// Animate based on scroll
<motion.div style={{ scaleX: scrollYProgress }} />
```

### Scroll-Linked Parallax

```tsx
const { scrollYProgress } = useScroll();
const y = useTransform(scrollYProgress, [0, 1], [0, -200]);

<motion.div style={{ y }}>
  Parallax content
</motion.div>
```

---

## 6. Motion Hooks

### useMotionValue

```tsx
const x = useMotionValue(0);

<motion.div style={{ x }} drag="x" />
```

### useTransform

```tsx
const x = useMotionValue(0);
const opacity = useTransform(x, [-100, 0, 100], [0, 1, 0]);
const background = useTransform(
  x,
  [-100, 0, 100],
  ["#ff0000", "#ffffff", "#00ff00"]
);
```

### useSpring

```tsx
const x = useMotionValue(0);
const springX = useSpring(x, { stiffness: 300, damping: 30 });
```

### useVelocity

```tsx
const x = useMotionValue(0);
const velocityX = useVelocity(x);
const scale = useTransform(velocityX, [-500, 0, 500], [0.8, 1, 0.8]);
```

### useInView

```tsx
const ref = useRef(null);
const isInView = useInView(ref, { once: true });

<motion.div
  ref={ref}
  initial={{ opacity: 0 }}
  animate={isInView ? { opacity: 1 } : {}}
/>
```

---

## 7. Layout Animations

### Auto Layout

```tsx
<motion.div layout>
  {/* Size/position changes animate automatically */}
</motion.div>
```

### Layout ID (Shared Element)

```tsx
// Card in list
<motion.div layoutId={`card-${id}`}>
  <h2>{title}</h2>
</motion.div>

// Expanded card (same layoutId)
<motion.div layoutId={`card-${id}`}>
  <h2>{title}</h2>
  <p>{description}</p>
</motion.div>
```

### Layout Types

| Value | Animates |
|-------|----------|
| `layout` | Size + position |
| `layout="position"` | Only position |
| `layout="size"` | Only size |

---

## 8. Variants System

### Defining Variants

```tsx
const cardVariants = {
  initial: { opacity: 0, y: 20 },
  animate: { opacity: 1, y: 0 },
  hover: { scale: 1.02, boxShadow: "0 10px 30px rgba(0,0,0,0.2)" },
  tap: { scale: 0.98 },
  exit: { opacity: 0, y: -20 }
};

<motion.div
  variants={cardVariants}
  initial="initial"
  animate="animate"
  whileHover="hover"
  whileTap="tap"
  exit="exit"
/>
```

### Orchestration

```tsx
const containerVariants = {
  hidden: {},
  visible: {
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.3
    }
  }
};

const itemVariants = {
  hidden: { opacity: 0, x: -20 },
  visible: { opacity: 1, x: 0 }
};
```

---

## 9. Performance Optimization

### GPU-Accelerated Properties

| ✅ Use | ❌ Avoid |
|--------|----------|
| `transform` (x, y, scale, rotate) | `width`, `height` |
| `opacity` | `margin`, `padding` |
| | `top`, `left`, `right`, `bottom` |

### Performance Tips

| Tip | Implementation |
|-----|----------------|
| Use transform over layout properties | `x`, `y` instead of `left`, `top` |
| Avoid onUpdate callback | Triggers every frame |
| Use layout prop sparingly | Can cause reflows |
| Lazy load with useInView | Animate only when visible |
| Don't animate too many elements | Limit to 10-20 simultaneous |

### Hardware Acceleration Warning

These patterns may **disable GPU acceleration**:

```tsx
// ❌ Avoid
<motion.div onUpdate={(latest) => console.log(latest)} />
<motion.div style={{ x: motionValue }} /> // MotionValue in style
transition={{ repeatDelay: 1 }} // repeatDelay
transition={{ damping: 0 }} // Zero damping
```

---

## 10. Accessibility

### Respect Reduced Motion

```tsx
// Option 1: MotionConfig (Recommended)
<MotionConfig reducedMotion="user">
  <App />
</MotionConfig>

// Option 2: useReducedMotion hook
const shouldReduce = useReducedMotion();

<motion.div
  animate={shouldReduce ? { opacity: 1 } : { opacity: 1, y: 0 }}
/>
```

### MotionConfig Options

| Value | Behavior |
|-------|----------|
| `"user"` | Respect OS preference |
| `"always"` | Always reduce motion |
| `"never"` | Ignore preference |

### What Gets Disabled

When reduced motion is active:
- ✅ `opacity` still animates
- ✅ `backgroundColor` still animates
- ❌ `transform` (x, y, scale, rotate) - instant
- ❌ Layout animations - instant

---

## 11. Common Patterns Reference

For detailed implementations with full code examples:

- **Page Transitions**: See [references/page-transitions.md](references/page-transitions.md)
- **Modal/Dialog**: See [references/modal-patterns.md](references/modal-patterns.md)
- **List Animations**: See [references/list-patterns.md](references/list-patterns.md)
- **Micro-interactions**: See [references/micro-interactions.md](references/micro-interactions.md)

---

## 12. Quick Reference

### Easing Functions

| Name | Feel |
|------|------|
| `"easeIn"` | Slow start |
| `"easeOut"` | Slow end (most natural) |
| `"easeInOut"` | Slow both ends |
| `"linear"` | Constant speed |
| `"anticipate"` | Pull back then forward |
| `"backIn"` / `"backOut"` | Overshoot effect |

### Spring Presets

| Feel | Config |
|------|--------|
| Snappy | `stiffness: 400, damping: 25` |
| Bouncy | `stiffness: 300, damping: 10` |
| Smooth | `stiffness: 100, damping: 20` |
| Gentle | `stiffness: 50, damping: 15` |

### Duration Guidelines

| Animation Type | Duration |
|----------------|----------|
| Micro-interactions | 100-200ms |
| UI feedback | 200-300ms |
| Transitions | 300-500ms |
| Page transitions | 400-600ms |
| Complex sequences | 500-1000ms |

---

> **Remember:** Animations should enhance UX, not distract. Use motion purposefully to guide attention, provide feedback, and create delight.
