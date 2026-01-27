# React Rendering Deep Dive

> Understanding React's render cycle for precise optimization.

---

## Table of Contents

1. [When React Re-renders](#when-react-re-renders)
2. [Preventing Unnecessary Renders](#preventing-unnecessary-renders)
3. [State Management & Performance](#state-management--performance)
4. [Advanced Patterns](#advanced-patterns)

---

## When React Re-renders

### Render Triggers

| Trigger | Description |
|---------|-------------|
| State change | `useState` setter called |
| Props change | Parent passes new props (reference) |
| Context change | Any Provider value changes |
| Parent re-renders | Children re-render by default |
| Force update | `useReducer` dispatch, key change |

### Understanding Reference Equality

```tsx
// Objects are compared by reference, not value
const obj1 = { name: "John" };
const obj2 = { name: "John" };

obj1 === obj2; // false (different references)

// This causes re-renders even with "same" data
function Parent() {
  // New object every render!
  return <Child config={{ theme: "dark" }} />;
}
```

---

## Preventing Unnecessary Renders

### React.memo Deep Dive

```tsx
// Basic usage
const MemoizedComponent = React.memo(function MyComponent({ data }) {
  console.log("Rendered");
  return <div>{data.name}</div>;
});

// With custom comparison
const MemoizedComponent = React.memo(
  function MyComponent({ user, onClick }) {
    return <button onClick={onClick}>{user.name}</button>;
  },
  (prevProps, nextProps) => {
    // Return true if props are equal (skip render)
    // Return false if props different (re-render)
    return (
      prevProps.user.id === nextProps.user.id &&
      prevProps.onClick === nextProps.onClick
    );
  }
);
```

### When React.memo Fails

```tsx
// ❌ Inline object breaks memoization
<MemoizedChild options={{ sort: true }} />

// ❌ Inline function breaks memoization
<MemoizedChild onClick={() => handleClick(id)} />

// ❌ Children as elements always create new references
<MemoizedWrapper>
  <div>Content</div>
</MemoizedWrapper>

// ✅ Fix with useMemo/useCallback
const options = useMemo(() => ({ sort: true }), []);
const handleClick = useCallback(() => onClick(id), [id, onClick]);

// ✅ Or pass children as render prop
<MemoizedWrapper render={() => <div>Content</div>} />
```

### useMemo vs useCallback

```tsx
// useMemo: Memoize computed VALUE
const sortedList = useMemo(() => {
  return [...items].sort((a, b) => a.name.localeCompare(b.name));
}, [items]);

// useCallback: Memoize FUNCTION reference
const handleSort = useCallback((key) => {
  setSortKey(key);
}, []);

// They're essentially the same under the hood:
useCallback(fn, deps) === useMemo(() => fn, deps)
```

### Dependency Array Best Practices

```tsx
// ✅ Include all values referenced inside
const filteredItems = useMemo(() => {
  return items.filter(item => item.category === category);
}, [items, category]); // Both referenced

// ❌ Missing dependency (stale closure)
const handleSubmit = useCallback(() => {
  submitForm(formData); // formData referenced but not in deps!
}, []); // Bug: Always uses initial formData

// ✅ Fixed
const handleSubmit = useCallback(() => {
  submitForm(formData);
}, [formData]);

// 💡 Use ref for values you don't want to trigger updates
const latestFormData = useRef(formData);
latestFormData.current = formData;

const handleSubmit = useCallback(() => {
  submitForm(latestFormData.current);
}, []); // Stable but always has latest data
```

---

## State Management & Performance

### State Colocation

```tsx
// ❌ Bad: State too high causes many re-renders
function App() {
  const [inputValue, setInputValue] = useState("");
  
  return (
    <>
      <Header /> {/* Re-renders on every keystroke */}
      <Sidebar /> {/* Re-renders on every keystroke */}
      <SearchInput value={inputValue} onChange={setInputValue} />
      <Results query={inputValue} />
    </>
  );
}

// ✅ Good: State colocated where needed
function App() {
  return (
    <>
      <Header />
      <Sidebar />
      <SearchSection /> {/* Contains its own state */}
    </>
  );
}

function SearchSection() {
  const [inputValue, setInputValue] = useState("");
  
  return (
    <>
      <SearchInput value={inputValue} onChange={setInputValue} />
      <Results query={inputValue} />
    </>
  );
}
```

### Lifting Content Up (Children Pattern)

```tsx
// ❌ ExpensiveComponent re-renders when count changes
function Parent() {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>
        Count: {count}
      </button>
      <ExpensiveComponent /> {/* Re-renders! */}
    </div>
  );
}

// ✅ ExpensiveComponent passed as children doesn't re-render
function CounterWrapper({ children }) {
  const [count, setCount] = useState(0);
  
  return (
    <div>
      <button onClick={() => setCount(c => c + 1)}>
        Count: {count}
      </button>
      {children} {/* Doesn't re-render! */}
    </div>
  );
}

function App() {
  return (
    <CounterWrapper>
      <ExpensiveComponent />
    </CounterWrapper>
  );
}
```

### Context Optimization

```tsx
// ❌ Bad: Single context with mixed concerns
const AppContext = createContext();

function AppProvider({ children }) {
  const [user, setUser] = useState(null);
  const [theme, setTheme] = useState("light");
  const [notifications, setNotifications] = useState([]);
  
  // Every consumer re-renders when ANY value changes
  return (
    <AppContext.Provider value={{ 
      user, setUser, 
      theme, setTheme, 
      notifications, setNotifications 
    }}>
      {children}
    </AppContext.Provider>
  );
}

// ✅ Good: Separate contexts for different update frequencies
const UserContext = createContext();
const ThemeContext = createContext();
const NotificationsContext = createContext();

// Even better: Separate state and dispatch
const ThemeStateContext = createContext();
const ThemeDispatchContext = createContext();

function ThemeProvider({ children }) {
  const [theme, setTheme] = useState("light");
  
  return (
    <ThemeStateContext.Provider value={theme}>
      <ThemeDispatchContext.Provider value={setTheme}>
        {children}
      </ThemeDispatchContext.Provider>
    </ThemeStateContext.Provider>
  );
}

// Components that only dispatch don't re-render on state change
function ThemeToggle() {
  const setTheme = useContext(ThemeDispatchContext);
  // ...
}
```

---

## Advanced Patterns

### Virtualization for Long Lists

```tsx
import { useVirtualizer } from "@tanstack/react-virtual";

function VirtualizedList({ items }) {
  const parentRef = useRef(null);
  
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50, // Estimated row height
  });
  
  return (
    <div ref={parentRef} style={{ height: 400, overflow: "auto" }}>
      <div style={{ height: virtualizer.getTotalSize() }}>
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.key}
            style={{
              position: "absolute",
              top: virtualRow.start,
              height: virtualRow.size,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  );
}
```

### Deferred Values

```tsx
import { useDeferredValue, useMemo } from "react";

function SearchResults({ query }) {
  // Deferred value updates with lower priority
  const deferredQuery = useDeferredValue(query);
  
  // Heavy filtering runs with deferred value
  const results = useMemo(() => {
    return heavyFilter(items, deferredQuery);
  }, [deferredQuery]);
  
  // Show stale indicator while updating
  const isStale = query !== deferredQuery;
  
  return (
    <div style={{ opacity: isStale ? 0.5 : 1 }}>
      {results.map(item => <Item key={item.id} item={item} />)}
    </div>
  );
}
```

### Transitions

```tsx
import { useTransition, useState } from "react";

function TabContainer() {
  const [tab, setTab] = useState("home");
  const [isPending, startTransition] = useTransition();
  
  function selectTab(nextTab) {
    // Mark as non-urgent update
    startTransition(() => {
      setTab(nextTab);
    });
  }
  
  return (
    <>
      <TabButton onClick={() => selectTab("home")}>Home</TabButton>
      <TabButton onClick={() => selectTab("posts")}>Posts</TabButton>
      
      <div style={{ opacity: isPending ? 0.7 : 1 }}>
        {tab === "home" && <Home />}
        {tab === "posts" && <Posts />}
      </div>
    </>
  );
}
```

### Key-Based Reset

```tsx
// Force component remount when user changes
function UserProfile({ userId }) {
  // Component remounts, state resets when key changes
  return <ProfileForm key={userId} userId={userId} />;
}

function ProfileForm({ userId }) {
  const [name, setName] = useState(""); // Fresh state per user
  // ...
}
```

---

## Performance Debugging

### React DevTools Profiler

1. Install React DevTools browser extension
2. Open DevTools → Profiler tab
3. Click Record
4. Interact with app
5. Stop recording
6. Analyze:
   - Which components rendered?
   - Why did they render?
   - How long did each take?

### Highlight Updates

```tsx
// Settings → Highlight updates when components render
// Blue = normal, Yellow = slow, Red = very slow
```

### Console Logging Renders

```tsx
function MyComponent({ prop }) {
  console.log("MyComponent rendered", prop);
  
  useEffect(() => {
    console.log("MyComponent mounted");
    return () => console.log("MyComponent unmounted");
  }, []);
  
  return <div>{prop}</div>;
}
```

---

## Quick Reference

### When to Optimize

| Symptom | Tool | Solution |
|---------|------|----------|
| Sluggish typing | Profiler | Debounce, deferred value |
| Slow list scrolling | Profiler | Virtualization |
| Janky animations | Performance tab | Reduce layout thrashing |
| High memory | Memory tab | Fix leaks, reduce state |

### Optimization Priority

1. **State colocation** - Move state closer to where it's used
2. **Component composition** - Children pattern, render props
3. **Context splitting** - Separate high/low frequency updates
4. **Memoization** - React.memo, useMemo, useCallback
5. **Virtualization** - For long lists (1000+ items)
6. **Concurrent features** - useTransition, useDeferredValue
