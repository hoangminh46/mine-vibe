# Micro-Interactions

> Delightful details that enhance user experience.

---

## Table of Contents

1. [Button Effects](#button-effects)
2. [Loading States](#loading-states)
3. [Notifications](#notifications)
4. [Toggle Switches](#toggle-switches)
5. [Input Effects](#input-effects)
6. [Icon Animations](#icon-animations)
7. [Progress Indicators](#progress-indicators)

---

## Button Effects

### Scale + Shadow

```tsx
<motion.button
  whileHover={{ 
    scale: 1.02,
    boxShadow: "0 5px 15px rgba(0,0,0,0.1)"
  }}
  whileTap={{ scale: 0.98 }}
  transition={{ type: "spring", stiffness: 400, damping: 17 }}
>
  Click me
</motion.button>
```

### Glow Effect

```tsx
<motion.button
  className="relative overflow-hidden"
  whileHover="hover"
>
  <span className="relative z-10">Submit</span>
  <motion.div
    className="absolute inset-0 bg-gradient-to-r from-blue-400 to-purple-500 opacity-0"
    variants={{ hover: { opacity: 0.2 } }}
  />
</motion.button>
```

### Icon Slide

```tsx
<motion.button
  className="flex items-center gap-2"
  whileHover="hover"
>
  <span>Learn more</span>
  <motion.span
    variants={{ hover: { x: 5 } }}
    transition={{ type: "spring", stiffness: 400 }}
  >
    →
  </motion.span>
</motion.button>
```

### Magnetic Effect

```tsx
function MagneticButton({ children }) {
  const x = useMotionValue(0);
  const y = useMotionValue(0);

  function handleMouse(event) {
    const rect = event.currentTarget.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    
    x.set((event.clientX - centerX) * 0.1);
    y.set((event.clientY - centerY) * 0.1);
  }

  function handleMouseLeave() {
    x.set(0);
    y.set(0);
  }

  return (
    <motion.button
      style={{ x, y }}
      onMouseMove={handleMouse}
      onMouseLeave={handleMouseLeave}
      transition={{ type: "spring", stiffness: 300, damping: 20 }}
    >
      {children}
    </motion.button>
  );
}
```

---

## Loading States

### Spinner

```tsx
<motion.div
  className="w-8 h-8 border-3 border-t-blue-500 border-gray-200 rounded-full"
  animate={{ rotate: 360 }}
  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
/>
```

### Pulse Dots

```tsx
function LoadingDots() {
  return (
    <div className="flex gap-1">
      {[0, 1, 2].map((i) => (
        <motion.div
          key={i}
          className="w-2 h-2 bg-blue-500 rounded-full"
          animate={{ scale: [1, 1.2, 1] }}
          transition={{
            duration: 0.6,
            repeat: Infinity,
            delay: i * 0.1,
          }}
        />
      ))}
    </div>
  );
}
```

### Skeleton

```tsx
<motion.div
  className="h-4 bg-gray-200 rounded"
  animate={{ opacity: [0.5, 1, 0.5] }}
  transition={{ duration: 1.5, repeat: Infinity, ease: "easeInOut" }}
/>
```

### Button Loading State

```tsx
function LoadingButton({ isLoading, children, ...props }) {
  return (
    <motion.button
      {...props}
      disabled={isLoading}
      whileTap={!isLoading ? { scale: 0.98 } : {}}
    >
      <AnimatePresence mode="wait">
        {isLoading ? (
          <motion.span
            key="loading"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="flex items-center gap-2"
          >
            <motion.span
              animate={{ rotate: 360 }}
              transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
            >
              ⟳
            </motion.span>
            Loading...
          </motion.span>
        ) : (
          <motion.span
            key="content"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
          >
            {children}
          </motion.span>
        )}
      </AnimatePresence>
    </motion.button>
  );
}
```

---

## Notifications

### Toast Notification

```tsx
const toastVariants = {
  initial: { opacity: 0, y: -20, scale: 0.9 },
  animate: { opacity: 1, y: 0, scale: 1 },
  exit: { opacity: 0, y: -20, scale: 0.9, transition: { duration: 0.2 } },
};

function Toast({ message, type = "info", onClose }) {
  useEffect(() => {
    const timer = setTimeout(onClose, 3000);
    return () => clearTimeout(timer);
  }, [onClose]);

  return (
    <motion.div
      variants={toastVariants}
      initial="initial"
      animate="animate"
      exit="exit"
      className={`toast toast-${type}`}
      whileHover={{ scale: 1.02 }}
    >
      <span>{message}</span>
      <motion.button 
        onClick={onClose}
        whileHover={{ scale: 1.1 }}
        whileTap={{ scale: 0.9 }}
      >
        ✕
      </motion.button>
    </motion.div>
  );
}
```

### Badge Pulse

```tsx
<div className="relative">
  <button>Notifications</button>
  <motion.span
    className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full"
    initial={{ scale: 0 }}
    animate={{ scale: 1 }}
    transition={{ type: "spring", stiffness: 500, damping: 15 }}
  >
    <motion.span
      className="absolute inset-0 bg-red-500 rounded-full"
      animate={{ scale: [1, 1.5], opacity: [0.5, 0] }}
      transition={{ duration: 1, repeat: Infinity }}
    />
    <span className="relative z-10 text-xs text-white flex items-center justify-center">
      3
    </span>
  </motion.span>
</div>
```

---

## Toggle Switches

### Basic Toggle

```tsx
function Toggle({ isOn, onToggle }) {
  return (
    <motion.button
      className={`w-14 h-8 rounded-full p-1 ${isOn ? 'bg-blue-500' : 'bg-gray-300'}`}
      onClick={onToggle}
      animate={{ backgroundColor: isOn ? "#3b82f6" : "#d1d5db" }}
    >
      <motion.div
        className="w-6 h-6 bg-white rounded-full shadow"
        animate={{ x: isOn ? 24 : 0 }}
        transition={{ type: "spring", stiffness: 500, damping: 30 }}
      />
    </motion.button>
  );
}
```

### Toggle with Icon

```tsx
function ThemeToggle({ isDark, onToggle }) {
  return (
    <motion.button
      className="w-12 h-12 rounded-full bg-gray-100 dark:bg-gray-800"
      onClick={onToggle}
      whileHover={{ scale: 1.05 }}
      whileTap={{ scale: 0.95 }}
    >
      <AnimatePresence mode="wait">
        <motion.span
          key={isDark ? "moon" : "sun"}
          initial={{ rotate: -90, opacity: 0 }}
          animate={{ rotate: 0, opacity: 1 }}
          exit={{ rotate: 90, opacity: 0 }}
          transition={{ duration: 0.2 }}
        >
          {isDark ? "🌙" : "☀️"}
        </motion.span>
      </AnimatePresence>
    </motion.button>
  );
}
```

---

## Input Effects

### Floating Label

```tsx
function FloatingInput({ label, ...props }) {
  const [isFocused, setIsFocused] = useState(false);
  const [hasValue, setHasValue] = useState(false);
  const isFloating = isFocused || hasValue;

  return (
    <div className="relative">
      <motion.label
        className="absolute left-3 pointer-events-none text-gray-500"
        animate={{
          y: isFloating ? -24 : 0,
          scale: isFloating ? 0.85 : 1,
          color: isFocused ? "#3b82f6" : "#6b7280",
        }}
        transition={{ duration: 0.2 }}
      >
        {label}
      </motion.label>
      <input
        className="w-full px-3 py-2 border rounded-lg"
        onFocus={() => setIsFocused(true)}
        onBlur={(e) => {
          setIsFocused(false);
          setHasValue(!!e.target.value);
        }}
        {...props}
      />
    </div>
  );
}
```

### Shake on Error

```tsx
function ShakeInput({ hasError, ...props }) {
  return (
    <motion.input
      animate={hasError ? {
        x: [0, -10, 10, -10, 10, 0],
        borderColor: "#ef4444",
      } : {}}
      transition={{ duration: 0.4 }}
      className="border rounded-lg px-3 py-2"
      {...props}
    />
  );
}
```

---

## Icon Animations

### Menu Toggle

```tsx
function MenuIcon({ isOpen }) {
  return (
    <motion.svg width="24" height="24" viewBox="0 0 24 24">
      <motion.line
        x1="4" y1="6" x2="20" y2="6"
        stroke="currentColor"
        strokeWidth="2"
        animate={isOpen ? { rotate: 45, y: 6 } : { rotate: 0, y: 0 }}
        style={{ transformOrigin: "center" }}
      />
      <motion.line
        x1="4" y1="12" x2="20" y2="12"
        stroke="currentColor"
        strokeWidth="2"
        animate={{ opacity: isOpen ? 0 : 1. }}
      />
      <motion.line
        x1="4" y1="18" x2="20" y2="18"
        stroke="currentColor"
        strokeWidth="2"
        animate={isOpen ? { rotate: -45, y: -6 } : { rotate: 0, y: 0 }}
        style={{ transformOrigin: "center" }}
      />
    </motion.svg>
  );
}
```

### Checkmark

```tsx
function AnimatedCheckmark({ isVisible }) {
  return (
    <AnimatePresence>
      {isVisible && (
        <motion.svg
          width="24"
          height="24"
          viewBox="0 0 24 24"
          initial={{ scale: 0 }}
          animate={{ scale: 1 }}
          exit={{ scale: 0 }}
        >
          <motion.path
            d="M5 12l5 5L20 7"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
            initial={{ pathLength: 0 }}
            animate={{ pathLength: 1 }}
            transition={{ duration: 0.3, delay: 0.1 }}
          />
        </motion.svg>
      )}
    </AnimatePresence>
  );
}
```

---

## Progress Indicators

### Circular Progress

```tsx
function CircularProgress({ progress }) {
  const circumference = 2 * Math.PI * 40; // radius = 40

  return (
    <svg width="100" height="100">
      <circle
        cx="50" cy="50" r="40"
        fill="none"
        stroke="#e5e7eb"
        strokeWidth="8"
      />
      <motion.circle
        cx="50" cy="50" r="40"
        fill="none"
        stroke="#3b82f6"
        strokeWidth="8"
        strokeLinecap="round"
        strokeDasharray={circumference}
        initial={{ strokeDashoffset: circumference }}
        animate={{ strokeDashoffset: circumference * (1 - progress) }}
        style={{ transform: "rotate(-90deg)", transformOrigin: "center" }}
      />
    </svg>
  );
}
```

### Linear Progress

```tsx
function LinearProgress({ progress }) {
  return (
    <div className="h-2 bg-gray-200 rounded-full overflow-hidden">
      <motion.div
        className="h-full bg-blue-500 rounded-full"
        initial={{ width: 0 }}
        animate={{ width: `${progress * 100}%` }}
        transition={{ duration: 0.5, ease: "easeOut" }}
      />
    </div>
  );
}
```

### Step Progress

```tsx
function StepProgress({ currentStep, totalSteps }) {
  return (
    <div className="flex items-center gap-2">
      {Array.from({ length: totalSteps }).map((_, i) => (
        <React.Fragment key={i}>
          <motion.div
            className={`w-8 h-8 rounded-full flex items-center justify-center ${
              i <= currentStep ? 'bg-blue-500 text-white' : 'bg-gray-200'
            }`}
            animate={{
              scale: i === currentStep ? 1.1 : 1,
              backgroundColor: i <= currentStep ? "#3b82f6" : "#e5e7eb",
            }}
          >
            {i + 1}
          </motion.div>
          {i < totalSteps - 1 && (
            <motion.div
              className="h-1 flex-1 bg-gray-200 rounded"
              style={{ overflow: "hidden" }}
            >
              <motion.div
                className="h-full bg-blue-500"
                initial={{ width: 0 }}
                animate={{ width: i < currentStep ? "100%" : "0%" }}
                transition={{ duration: 0.3 }}
              />
            </motion.div>
          )}
        </React.Fragment>
      ))}
    </div>
  );
}
```

---

## Best Practices

| Do | Don't |
|----|-------|
| Use spring for interactive elements | Use linear easing for UI animations |
| Keep micro-interactions < 300ms | Make users wait for animations |
| Provide immediate feedback | Delay response to user action |
| Match animation intensity to action | Use dramatic effects for minor actions |
| Test on low-end devices | Assume all devices perform equally |
