# Page Transitions

> Complete patterns for smooth page transitions in React/Next.js.

---

## Table of Contents

1. [Next.js App Router](#nextjs-app-router)
2. [Next.js Pages Router](#nextjs-pages-router)
3. [React Router](#react-router)
4. [Transition Variants](#transition-variants)

---

## Next.js App Router

### Template-Based Transition

```tsx
// app/template.tsx
"use client";
import { motion } from "framer-motion";

export default function Template({ children }: { children: React.ReactNode }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3, ease: "easeOut" }}
    >
      {children}
    </motion.div>
  );
}
```

### With AnimatePresence

```tsx
// components/PageTransition.tsx
"use client";
import { AnimatePresence, motion } from "framer-motion";
import { usePathname } from "next/navigation";

const variants = {
  initial: { opacity: 0, x: 20 },
  animate: { opacity: 1, x: 0 },
  exit: { opacity: 0, x: -20 },
};

export function PageTransition({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();

  return (
    <AnimatePresence mode="wait" initial={false}>
      <motion.div
        key={pathname}
        variants={variants}
        initial="initial"
        animate="animate"
        exit="exit"
        transition={{ duration: 0.3, ease: "easeInOut" }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

### Usage in Layout

```tsx
// app/layout.tsx
import { PageTransition } from "@/components/PageTransition";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Header />
        <PageTransition>{children}</PageTransition>
        <Footer />
      </body>
    </html>
  );
}
```

---

## Next.js Pages Router

### _app.tsx Setup

```tsx
// pages/_app.tsx
import { AnimatePresence, motion } from "framer-motion";
import type { AppProps } from "next/app";

const pageVariants = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
};

export default function App({ Component, pageProps, router }: AppProps) {
  return (
    <AnimatePresence mode="wait" initial={false}>
      <motion.div
        key={router.asPath}
        variants={pageVariants}
        initial="initial"
        animate="animate"
        exit="exit"
        transition={{ duration: 0.3 }}
      >
        <Component {...pageProps} />
      </motion.div>
    </AnimatePresence>
  );
}
```

---

## React Router

### With createBrowserRouter

```tsx
import { AnimatePresence, motion } from "framer-motion";
import { useLocation, useOutlet } from "react-router-dom";

function AnimatedOutlet() {
  const location = useLocation();
  const outlet = useOutlet();

  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location.pathname}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        exit={{ opacity: 0, y: -20 }}
        transition={{ duration: 0.3 }}
      >
        {outlet}
      </motion.div>
    </AnimatePresence>
  );
}
```

---

## Transition Variants

### Fade

```tsx
const fadeVariants = {
  initial: { opacity: 0 },
  animate: { opacity: 1 },
  exit: { opacity: 0 },
};
```

### Slide Right

```tsx
const slideRightVariants = {
  initial: { opacity: 0, x: -50 },
  animate: { opacity: 1, x: 0 },
  exit: { opacity: 0, x: 50 },
};
```

### Slide Up

```tsx
const slideUpVariants = {
  initial: { opacity: 0, y: 30 },
  animate: { opacity: 1, y: 0 },
  exit: { opacity: 0, y: -30 },
};
```

### Scale

```tsx
const scaleVariants = {
  initial: { opacity: 0, scale: 0.95 },
  animate: { opacity: 1, scale: 1 },
  exit: { opacity: 0, scale: 1.05 },
};
```

### Flip (3D)

```tsx
const flipVariants = {
  initial: { opacity: 0, rotateY: -90 },
  animate: { opacity: 1, rotateY: 0 },
  exit: { opacity: 0, rotateY: 90 },
};
```

### Blur (with filter)

```tsx
const blurVariants = {
  initial: { opacity: 0, filter: "blur(10px)" },
  animate: { opacity: 1, filter: "blur(0px)" },
  exit: { opacity: 0, filter: "blur(10px)" },
};
```

---

## Direction-Aware Transitions

```tsx
"use client";
import { useState, useEffect } from "react";
import { usePathname } from "next/navigation";

// Track navigation direction
export function useNavigationDirection() {
  const pathname = usePathname();
  const [direction, setDirection] = useState(0);
  const [prevPath, setPrevPath] = useState(pathname);

  useEffect(() => {
    if (pathname !== prevPath) {
      // Simple heuristic: compare path lengths
      setDirection(pathname.length > prevPath.length ? 1 : -1);
      setPrevPath(pathname);
    }
  }, [pathname, prevPath]);

  return direction;
}

// Usage in component
function PageTransition({ children }) {
  const direction = useNavigationDirection();
  
  const variants = {
    initial: { opacity: 0, x: direction * 50 },
    animate: { opacity: 1, x: 0 },
    exit: { opacity: 0, x: direction * -50 },
  };

  return (
    <motion.div variants={variants} initial="initial" animate="animate" exit="exit">
      {children}
    </motion.div>
  );
}
```

---

## Performance Tips

| Tip | Why |
|-----|-----|
| Use `initial={false}` on SSR | Prevents flash on first load |
| Keep transitions under 500ms | Users perceive delays > 400ms |
| Use `transform` not `left/top` | GPU accelerated |
| Avoid animating during hydration | Can cause layout shift |
