# List Animation Patterns

> Smooth, performant list animations for React.

---

## Table of Contents

1. [Stagger Animation](#stagger-animation)
2. [Reorder List](#reorder-list)
3. [Add/Remove Items](#addremove-items)
4. [Infinite Scroll](#infinite-scroll)
5. [Accordion List](#accordion-list)

---

## Stagger Animation

### Basic Stagger

```tsx
const containerVariants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.08,
      delayChildren: 0.1,
    },
  },
};

const itemVariants = {
  hidden: { opacity: 0, y: 20 },
  visible: { 
    opacity: 1, 
    y: 0,
    transition: { type: "spring", stiffness: 300, damping: 24 }
  },
};

export function StaggerList({ items }) {
  return (
    <motion.ul
      variants={containerVariants}
      initial="hidden"
      animate="visible"
    >
      {items.map((item) => (
        <motion.li key={item.id} variants={itemVariants}>
          {item.content}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

### Stagger on Scroll

```tsx
export function StaggerOnScroll({ items }) {
  return (
    <motion.ul
      initial="hidden"
      whileInView="visible"
      viewport={{ once: true, margin: "-50px" }}
      variants={{
        visible: { transition: { staggerChildren: 0.1 } }
      }}
    >
      {items.map((item) => (
        <motion.li
          key={item.id}
          variants={{
            hidden: { opacity: 0, x: -20 },
            visible: { opacity: 1, x: 0 }
          }}
        >
          {item.content}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

---

## Reorder List

### With Reorder Component

```tsx
import { Reorder } from "framer-motion";

export function ReorderableList() {
  const [items, setItems] = useState([
    { id: 1, text: "Item 1" },
    { id: 2, text: "Item 2" },
    { id: 3, text: "Item 3" },
  ]);

  return (
    <Reorder.Group 
      axis="y" 
      values={items} 
      onReorder={setItems}
      className="space-y-2"
    >
      {items.map((item) => (
        <Reorder.Item
          key={item.id}
          value={item}
          className="bg-white p-4 rounded-lg shadow cursor-grab active:cursor-grabbing"
          whileDrag={{ 
            scale: 1.02, 
            boxShadow: "0 10px 30px rgba(0,0,0,0.15)" 
          }}
        >
          {item.text}
        </Reorder.Item>
      ))}
    </Reorder.Group>
  );
}
```

### Custom Drag Handle

```tsx
import { Reorder, useDragControls } from "framer-motion";

function DraggableItem({ item }) {
  const controls = useDragControls();

  return (
    <Reorder.Item
      value={item}
      dragListener={false}
      dragControls={controls}
      className="flex items-center gap-3 bg-white p-4 rounded-lg"
    >
      <button
        className="cursor-grab active:cursor-grabbing p-1"
        onPointerDown={(e) => controls.start(e)}
      >
        ⣿
      </button>
      <span>{item.text}</span>
    </Reorder.Item>
  );
}
```

---

## Add/Remove Items

### With AnimatePresence

```tsx
import { AnimatePresence, motion } from "framer-motion";

const itemVariants = {
  initial: { opacity: 0, height: 0, marginBottom: 0 },
  animate: { 
    opacity: 1, 
    height: "auto", 
    marginBottom: 8,
    transition: { type: "spring", stiffness: 300, damping: 24 }
  },
  exit: { 
    opacity: 0, 
    height: 0, 
    marginBottom: 0,
    transition: { duration: 0.2 }
  },
};

export function DynamicList() {
  const [items, setItems] = useState([]);

  const addItem = () => {
    setItems([...items, { id: Date.now(), text: `Item ${items.length + 1}` }]);
  };

  const removeItem = (id) => {
    setItems(items.filter(item => item.id !== id));
  };

  return (
    <>
      <button onClick={addItem}>Add Item</button>
      
      <ul>
        <AnimatePresence mode="popLayout">
          {items.map((item) => (
            <motion.li
              key={item.id}
              variants={itemVariants}
              initial="initial"
              animate="animate"
              exit="exit"
              layout
              className="bg-white p-4 rounded-lg flex justify-between"
            >
              <span>{item.text}</span>
              <button onClick={() => removeItem(item.id)}>✕</button>
            </motion.li>
          ))}
        </AnimatePresence>
      </ul>
    </>
  );
}
```

### Layout Animation for Smooth Reflow

```tsx
// Add layout prop for smooth position transitions
<motion.li
  key={item.id}
  layout // This enables smooth position changes!
  initial={{ opacity: 0, scale: 0.8 }}
  animate={{ opacity: 1, scale: 1 }}
  exit={{ opacity: 0, scale: 0.8 }}
>
  {item.content}
</motion.li>
```

---

## Infinite Scroll

### With useInView

```tsx
import { motion, useInView } from "framer-motion";
import { useRef, useCallback } from "react";

export function InfiniteScrollList({ loadMore, hasMore, items }) {
  const loadMoreRef = useRef(null);
  const isInView = useInView(loadMoreRef);

  useEffect(() => {
    if (isInView && hasMore) {
      loadMore();
    }
  }, [isInView, hasMore, loadMore]);

  return (
    <ul>
      {items.map((item, index) => (
        <motion.li
          key={item.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: index * 0.05 }}
        >
          {item.content}
        </motion.li>
      ))}
      
      {/* Load more trigger */}
      <div ref={loadMoreRef}>
        {hasMore && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-center py-4"
          >
            Loading...
          </motion.div>
        )}
      </div>
    </ul>
  );
}
```

---

## Accordion List

### Expandable Items

```tsx
import { AnimatePresence, motion } from "framer-motion";

function AccordionItem({ title, content, isOpen, onToggle }) {
  return (
    <div className="border-b">
      <motion.button
        className="w-full py-4 flex justify-between items-center"
        onClick={onToggle}
        whileTap={{ scale: 0.98 }}
      >
        <span>{title}</span>
        <motion.span
          animate={{ rotate: isOpen ? 180 : 0 }}
          transition={{ duration: 0.2 }}
        >
          ▼
        </motion.span>
      </motion.button>
      
      <AnimatePresence initial={false}>
        {isOpen && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: "auto", opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.3, ease: "easeInOut" }}
            style={{ overflow: "hidden" }}
          >
            <div className="pb-4 text-gray-600">
              {content}
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}

export function Accordion({ items }) {
  const [openIndex, setOpenIndex] = useState(null);

  return (
    <div>
      {items.map((item, index) => (
        <AccordionItem
          key={item.id}
          title={item.title}
          content={item.content}
          isOpen={openIndex === index}
          onToggle={() => setOpenIndex(openIndex === index ? null : index)}
        />
      ))}
    </div>
  );
}
```

---

## Performance Tips

| Tip | Why |
|-----|-----|
| Use `layout` prop sparingly | Can cause reflows on large lists |
| Virtualize long lists | Use `react-window` + Framer Motion |
| Limit simultaneous animations | Max 10-15 items animating at once |
| Use `mode="popLayout"` | Better exit animations for lists |
| Debounce rapid add/remove | Batch state updates |
