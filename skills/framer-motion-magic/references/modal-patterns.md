# Modal & Dialog Patterns

> Accessible, animated modal patterns with Framer Motion.

---

## Table of Contents

1. [Basic Modal](#basic-modal)
2. [Modal with Backdrop](#modal-with-backdrop)
3. [Bottom Sheet](#bottom-sheet)
4. [Drawer](#drawer)
5. [Alert Dialog](#alert-dialog)
6. [Full Screen Modal](#full-screen-modal)

---

## Basic Modal

```tsx
import { AnimatePresence, motion } from "framer-motion";

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
}

const modalVariants = {
  hidden: { opacity: 0, scale: 0.95, y: 10 },
  visible: { opacity: 1, scale: 1, y: 0 },
  exit: { opacity: 0, scale: 0.95, y: 10 },
};

export function Modal({ isOpen, onClose, children }: ModalProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="modal-overlay"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
        >
          <motion.div
            className="modal-content"
            variants={modalVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
            transition={{ type: "spring", damping: 25, stiffness: 300 }}
            onClick={(e) => e.stopPropagation()}
          >
            {children}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

### Styles

```css
.modal-overlay {
  position: fixed;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0, 0, 0, 0.5);
  backdrop-filter: blur(4px);
  z-index: 50;
}

.modal-content {
  background: white;
  border-radius: 12px;
  padding: 24px;
  max-width: 500px;
  width: 90%;
  max-height: 85vh;
  overflow-y: auto;
}
```

---

## Modal with Backdrop

```tsx
const backdropVariants = {
  hidden: { opacity: 0 },
  visible: { opacity: 1 },
};

const modalVariants = {
  hidden: { opacity: 0, y: 50, scale: 0.9 },
  visible: { 
    opacity: 1, 
    y: 0, 
    scale: 1,
    transition: { 
      type: "spring",
      damping: 25,
      stiffness: 300,
      delay: 0.1 
    }
  },
  exit: { 
    opacity: 0, 
    y: 50, 
    scale: 0.9,
    transition: { duration: 0.2 }
  },
};

export function ModalWithBackdrop({ isOpen, onClose, children }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            className="fixed inset-0 bg-black/50 z-40"
            variants={backdropVariants}
            initial="hidden"
            animate="visible"
            exit="hidden"
            onClick={onClose}
          />
          
          {/* Modal */}
          <motion.div
            className="fixed inset-0 z-50 flex items-center justify-center p-4"
            variants={modalVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
          >
            <div 
              className="bg-white rounded-xl p-6 max-w-lg w-full"
              onClick={(e) => e.stopPropagation()}
            >
              {children}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
```

---

## Bottom Sheet

```tsx
const sheetVariants = {
  hidden: { y: "100%" },
  visible: { 
    y: 0,
    transition: { type: "spring", damping: 30, stiffness: 300 }
  },
  exit: { 
    y: "100%",
    transition: { duration: 0.3, ease: "easeIn" }
  },
};

export function BottomSheet({ isOpen, onClose, children }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            className="fixed inset-0 bg-black/40 z-40"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />
          
          <motion.div
            className="fixed bottom-0 left-0 right-0 z-50 bg-white rounded-t-2xl"
            variants={sheetVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
            drag="y"
            dragConstraints={{ top: 0 }}
            dragElastic={0.2}
            onDragEnd={(_, info) => {
              if (info.offset.y > 100 || info.velocity.y > 300) {
                onClose();
              }
            }}
          >
            {/* Drag Handle */}
            <div className="flex justify-center py-3">
              <div className="w-12 h-1.5 bg-gray-300 rounded-full" />
            </div>
            
            <div className="px-4 pb-8 max-h-[80vh] overflow-y-auto">
              {children}
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
```

---

## Drawer

```tsx
type DrawerSide = "left" | "right";

interface DrawerProps {
  isOpen: boolean;
  onClose: () => void;
  side?: DrawerSide;
  children: React.ReactNode;
}

export function Drawer({ isOpen, onClose, side = "right", children }: DrawerProps) {
  const xOffset = side === "right" ? "100%" : "-100%";

  return (
    <AnimatePresence>
      {isOpen && (
        <>
          <motion.div
            className="fixed inset-0 bg-black/50 z-40"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={onClose}
          />
          
          <motion.div
            className={`fixed top-0 bottom-0 ${side}-0 w-80 bg-white z-50 shadow-xl`}
            initial={{ x: xOffset }}
            animate={{ x: 0 }}
            exit={{ x: xOffset }}
            transition={{ type: "spring", damping: 30, stiffness: 300 }}
          >
            {children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}
```

---

## Alert Dialog

```tsx
const alertVariants = {
  hidden: { opacity: 0, scale: 0.8 },
  visible: { 
    opacity: 1, 
    scale: 1,
    transition: { type: "spring", damping: 15, stiffness: 300 }
  },
  exit: { opacity: 0, scale: 0.8 },
};

export function AlertDialog({ 
  isOpen, 
  onClose, 
  onConfirm,
  title,
  description,
  confirmText = "Confirm",
  cancelText = "Cancel"
}) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="fixed inset-0 z-50 flex items-center justify-center bg-black/50"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
        >
          <motion.div
            className="bg-white rounded-lg p-6 max-w-sm w-full mx-4 text-center"
            variants={alertVariants}
            initial="hidden"
            animate="visible"
            exit="exit"
          >
            <h2 className="text-xl font-semibold mb-2">{title}</h2>
            <p className="text-gray-600 mb-6">{description}</p>
            
            <div className="flex gap-3 justify-center">
              <motion.button
                className="px-4 py-2 rounded-lg border"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={onClose}
              >
                {cancelText}
              </motion.button>
              <motion.button
                className="px-4 py-2 rounded-lg bg-red-500 text-white"
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={() => { onConfirm(); onClose(); }}
              >
                {confirmText}
              </motion.button>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

---

## Full Screen Modal

```tsx
const fullScreenVariants = {
  hidden: { opacity: 0, scale: 0.9 },
  visible: { 
    opacity: 1, 
    scale: 1,
    transition: { duration: 0.3, ease: [0.4, 0, 0.2, 1] }
  },
  exit: { 
    opacity: 0, 
    scale: 0.9,
    transition: { duration: 0.2 }
  },
};

export function FullScreenModal({ isOpen, onClose, children }) {
  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          className="fixed inset-0 z-50 bg-white"
          variants={fullScreenVariants}
          initial="hidden"
          animate="visible"
          exit="exit"
        >
          <button
            className="absolute top-4 right-4 p-2"
            onClick={onClose}
          >
            ✕
          </button>
          {children}
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

---

## Accessibility Checklist

| Requirement | Implementation |
|-------------|----------------|
| Focus trap | Use `@radix-ui/react-focus-guards` |
| ESC to close | Add `onKeyDown` handler |
| ARIA attributes | `role="dialog"`, `aria-modal="true"` |
| Focus on open | `autoFocus` on first focusable element |
| Scroll lock | `overflow: hidden` on body |
| Reduced motion | Use `useReducedMotion` hook |

```tsx
// Example with accessibility
import { useReducedMotion } from "framer-motion";

function AccessibleModal({ isOpen, onClose, children }) {
  const shouldReduceMotion = useReducedMotion();
  
  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === "Escape") onClose();
    };
    
    if (isOpen) {
      document.addEventListener("keydown", handleEsc);
      document.body.style.overflow = "hidden";
    }
    
    return () => {
      document.removeEventListener("keydown", handleEsc);
      document.body.style.overflow = "";
    };
  }, [isOpen, onClose]);

  const transition = shouldReduceMotion 
    ? { duration: 0 } 
    : { type: "spring", damping: 25, stiffness: 300 };

  // ... rest of modal implementation
}
```
