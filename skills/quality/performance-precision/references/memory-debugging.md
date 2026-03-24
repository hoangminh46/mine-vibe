# Memory Debugging Guide

> Detect, diagnose, and fix memory leaks in JavaScript/React applications.

---

## Table of Contents

1. [Common Memory Leak Patterns](#common-memory-leak-patterns)
2. [React-Specific Leaks](#react-specific-leaks)
3. [Detection with Chrome DevTools](#detection-with-chrome-devtools)
4. [Fixing Memory Leaks](#fixing-memory-leaks)

---

## Common Memory Leak Patterns

### 1. Forgotten Timers

```tsx
// ❌ Memory leak: Timer continues after unmount
function Component() {
  useEffect(() => {
    setInterval(() => {
      console.log("Still running!");
    }, 1000);
  }, []);
}

// ✅ Fixed: Clear timer on cleanup
function Component() {
  useEffect(() => {
    const intervalId = setInterval(() => {
      console.log("Running");
    }, 1000);
    
    return () => clearInterval(intervalId);
  }, []);
}
```

### 2. Event Listeners

```tsx
// ❌ Memory leak: Listener not removed
function Component() {
  useEffect(() => {
    window.addEventListener("resize", handleResize);
  }, []);
}

// ✅ Fixed: Remove listener on cleanup
function Component() {
  useEffect(() => {
    window.addEventListener("resize", handleResize);
    
    return () => window.removeEventListener("resize", handleResize);
  }, []);
}

// ⚠️ Common mistake: Different function reference
function Component() {
  useEffect(() => {
    // This creates new function each time!
    window.addEventListener("resize", () => handleResize());
    
    // This won't remove the original listener!
    return () => window.removeEventListener("resize", () => handleResize());
  }, []);
}

// ✅ Correct: Use stable reference
function Component() {
  const handleResize = useCallback(() => {
    // handle resize
  }, []);
  
  useEffect(() => {
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, [handleResize]);
}
```

### 3. Active WebSocket Connections

```tsx
// ❌ Memory leak: Socket stays open
function ChatComponent() {
  useEffect(() => {
    const socket = new WebSocket("wss://api.example.com");
    socket.onmessage = (event) => {
      setMessages(m => [...m, event.data]);
    };
  }, []);
}

// ✅ Fixed: Close socket on cleanup
function ChatComponent() {
  useEffect(() => {
    const socket = new WebSocket("wss://api.example.com");
    
    socket.onmessage = (event) => {
      setMessages(m => [...m, event.data]);
    };
    
    return () => {
      socket.close();
    };
  }, []);
}
```

### 4. Pending Fetch Requests

```tsx
// ❌ Potential issue: Setting state after unmount
function Component({ userId }) {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    fetch(`/api/users/${userId}`)
      .then(res => res.json())
      .then(data => setUser(data)); // Component might be unmounted!
  }, [userId]);
}

// ✅ Fixed: AbortController
function Component({ userId }) {
  const [user, setUser] = useState(null);
  
  useEffect(() => {
    const controller = new AbortController();
    
    fetch(`/api/users/${userId}`, { signal: controller.signal })
      .then(res => res.json())
      .then(data => setUser(data))
      .catch(err => {
        if (err.name !== "AbortError") {
          console.error(err);
        }
      });
    
    return () => controller.abort();
  }, [userId]);
}
```

### 5. Closures Holding References

```tsx
// ❌ Closure keeps large object alive
function processData() {
  const largeData = new Array(1000000).fill("x");
  
  return function logger() {
    // This closure holds reference to largeData
    // even if we only use largeData.length
    console.log(largeData.length);
  };
}

// ✅ Fixed: Extract only what's needed
function processData() {
  const largeData = new Array(1000000).fill("x");
  const length = largeData.length; // Extract value
  
  return function logger() {
    console.log(length); // Only holds primitive
  };
}
```

### 6. DOM References

```tsx
// ❌ Memory leak: Detached DOM nodes
let cachedElement = null;

function createModal() {
  cachedElement = document.createElement("div");
  cachedElement.innerHTML = "Modal content";
  document.body.appendChild(cachedElement);
}

function removeModal() {
  document.body.removeChild(cachedElement);
  // cachedElement still holds reference!
}

// ✅ Fixed: Null the reference
function removeModal() {
  document.body.removeChild(cachedElement);
  cachedElement = null;
}
```

---

## React-Specific Leaks

### useRef Without Cleanup

```tsx
// ❌ Leak: Ref holds large object after unmount
function VideoPlayer({ videoUrl }) {
  const playerRef = useRef(null);
  
  useEffect(() => {
    playerRef.current = new HeavyVideoPlayer(videoUrl);
  }, [videoUrl]);
}

// ✅ Fixed: Clean up ref
function VideoPlayer({ videoUrl }) {
  const playerRef = useRef(null);
  
  useEffect(() => {
    playerRef.current = new HeavyVideoPlayer(videoUrl);
    
    return () => {
      playerRef.current.destroy();
      playerRef.current = null;
    };
  }, [videoUrl]);
}
```

### Subscriptions (Redux, Zustand, etc.)

```tsx
// ❌ Leak: Store subscription not cleaned
function Component() {
  const [state, setState] = useState();
  
  useEffect(() => {
    store.subscribe(() => {
      setState(store.getState());
    });
  }, []);
}

// ✅ Fixed: Unsubscribe
function Component() {
  const [state, setState] = useState();
  
  useEffect(() => {
    const unsubscribe = store.subscribe(() => {
      setState(store.getState());
    });
    
    return unsubscribe;
  }, []);
}
```

### Context Value Objects

```tsx
// ❌ Bad: New object every render causes all consumers to re-render
function Provider({ children }) {
  const [user, setUser] = useState(null);
  
  return (
    <UserContext.Provider value={{ user, setUser }}>
      {children}
    </UserContext.Provider>
  );
}

// ✅ Better: Memoize context value
function Provider({ children }) {
  const [user, setUser] = useState(null);
  
  const value = useMemo(() => ({ user, setUser }), [user]);
  
  return (
    <UserContext.Provider value={value}>
      {children}
    </UserContext.Provider>
  );
}
```

---

## Detection with Chrome DevTools

### Step-by-Step Heap Snapshot

1. **Open DevTools** → Memory tab
2. **Take baseline snapshot**
   - Click "Take snapshot"
   - Label it "Before"
3. **Perform suspected leaky action**
   - Navigate to page
   - Open/close modal
   - Repeat action 3-5 times
4. **Force garbage collection**
   - Click the trash can icon 🗑️
5. **Take another snapshot**
   - Label it "After"
6. **Compare snapshots**
   - Select "After" snapshot
   - Change view to "Comparison"
   - Select "Before" in dropdown
   - Look for unexpected retained objects

### What to Look For

| Column | Meaning |
|--------|---------|
| **# New** | Objects created between snapshots |
| **# Deleted** | Objects garbage collected |
| **# Delta** | Net change (New - Deleted) |
| **Size Delta** | Memory change |

### Red Flags

- Large positive **# Delta** for your component classes
- Growing **Detached DOM tree** count
- Increasing **Closure** count
- Arrays/Objects with unexpected size growth

### Finding Retainers

1. Click on suspicious object in snapshot
2. Look at "Retainers" panel below
3. Trace back to find what's keeping it alive
4. Common culprits:
   - Event listeners
   - Timers
   - Closures
   - Global variables

### Performance Timeline

1. **Open DevTools** → Performance tab
2. Enable **Memory** checkbox
3. Click **Record**
4. Perform actions
5. Click **Stop**
6. Analyze heap graph:
   - Steady line = Good
   - Stair-stepping up = Leak
   - Saw-tooth = Normal GC

---

## Fixing Memory Leaks

### Cleanup Pattern Template

```tsx
function Component() {
  useEffect(() => {
    // 1. Create resources
    const timer = setInterval(callback, 1000);
    const controller = new AbortController();
    window.addEventListener("event", handler);
    const subscription = store.subscribe(listener);
    
    // 2. Return cleanup function
    return () => {
      clearInterval(timer);
      controller.abort();
      window.removeEventListener("event", handler);
      subscription.unsubscribe();
    };
  }, []);
}
```

### Custom Hook for Safe State Updates

```tsx
function useSafeState<T>(initialValue: T) {
  const [state, setState] = useState(initialValue);
  const mountedRef = useRef(true);
  
  useEffect(() => {
    mountedRef.current = true;
    return () => {
      mountedRef.current = false;
    };
  }, []);
  
  const setSafeState = useCallback((value: T | ((prev: T) => T)) => {
    if (mountedRef.current) {
      setState(value);
    }
  }, []);
  
  return [state, setSafeState] as const;
}

// Usage
function Component() {
  const [data, setData] = useSafeState(null);
  
  useEffect(() => {
    fetchData().then(setData); // Safe even if component unmounts
  }, []);
}
```

### AbortController Helper Hook

```tsx
function useAbortController() {
  const controllerRef = useRef<AbortController>();
  
  useEffect(() => {
    return () => {
      controllerRef.current?.abort();
    };
  }, []);
  
  return useCallback(() => {
    // Cancel previous request
    controllerRef.current?.abort();
    // Create new controller
    controllerRef.current = new AbortController();
    return controllerRef.current.signal;
  }, []);
}

// Usage
function Component() {
  const getSignal = useAbortController();
  
  const fetchData = async () => {
    const signal = getSignal();
    await fetch(url, { signal });
  };
}
```

---

## Debugging Checklist

### When You Suspect a Leak

- [ ] Open Memory tab, take snapshot
- [ ] Perform action 3-5 times
- [ ] Force GC, take another snapshot
- [ ] Compare snapshots for growth
- [ ] Check Retainers for culprit

### Before Deploying

- [ ] All `setInterval` → `clearInterval`
- [ ] All `addEventListener` → `removeEventListener`
- [ ] All WebSocket → `.close()`
- [ ] All fetch → AbortController
- [ ] All subscriptions → unsubscribe
- [ ] All refs → null on cleanup

### Quick Wins

| Pattern | Fix |
|---------|-----|
| Timer leak | Return `clearInterval` from useEffect |
| Event leak | Use same function reference for add/remove |
| Fetch leak | Use AbortController |
| Ref leak | Set `ref.current = null` in cleanup |
| Subscription leak | Call unsubscribe in cleanup |
