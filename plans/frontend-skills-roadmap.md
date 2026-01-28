# 🎯 Frontend Skills Roadmap for Mine

> **Lập bởi**: Mine (AI Assistant)  
> **Ngày tạo**: 2026-01-27  
> **Dành cho**: Lập trình viên Front-end  
> **Mục đích**: Danh sách các Skills cần cài đặt để nâng cao năng lực của Mine

---

## 📊 Tổng quan

| # | Skill Name | Độ ưu tiên | Trạng thái | Mô tả ngắn |
|---|------------|-----------|-----------|------------|
| 1 | `framer-motion-magic` | 🔴 Cao | ✅ Đã cài | Animation & Micro-interactions |
| 2 | `performance-precision` | 🔴 Cao | ✅ Đã cài | Core Web Vitals & Tối ưu hiệu năng |
| 3 | `accessibility-guarantor` | 🟡 Trung bình | ⬜ Chưa cài | WCAG & A11y compliance |
| 4 | `design-system-architect` | 🟡 Trung bình | ⬜ Chưa cài | Design Tokens & Component Library |
| 5 | `testing-frontend-pro` | 🟡 Trung bình | ⬜ Chưa cài | Vitest, Testing Library, Playwright |
| 6 | `web-security-frontend` | 🟠 Khá cao | ✅ Đã cài | XSS, CSRF, CSP, Auth-flow |
| 7 | `responsive-mastery` | 🟡 Trung bình | ✅ Đã cài | Mobile-first & Touch optimization |
| 8 | `websocket-realtime-mastery` | 🟠 Khá cao | ✅ Đã cài | WebSocket, Socket.IO, Realtime Apps |

---

## 📝 Chi tiết từng Skill

### 1. 🎐 `framer-motion-magic` (Phù thủy Chuyển động)
**Độ ưu tiên**: 🔴 Cao  
**Thư viện liên quan**: `framer-motion`, `react-spring`, `@formkit/auto-animate`

**Nội dung cần bao gồm**:
- Thiết kế micro-interactions tinh tế (hover, click, focus states)
- Layout animations phức tạp mà không bị giật lag
- Page transitions mượt mà (AnimatePresence)
- Gesture-based animations (drag, pan, pinch)
- Stagger animations cho lists và grids
- Performance: GPU acceleration, will-change, transform vs position
- Patterns: Shared layout animations, Exit animations

**Use cases**:
- Hero sections với parallax effect
- Modal/Drawer với smooth entrance/exit
- Card hover effects
- Loading skeletons với shimmer effect
- Toast notifications với slide-in/out

---

### 2. ⚡ `performance-precision` (Tối ưu Hiệu năng Tuyệt đối)
**Độ ưu tiên**: 🔴 Cao  
**Công cụ liên quan**: Lighthouse, WebPageTest, Chrome DevTools Performance

**Nội dung cần bao gồm**:
- **Core Web Vitals**:
  - LCP (Largest Contentful Paint) < 2.5s
  - FID (First Input Delay) < 100ms
  - CLS (Cumulative Layout Shift) < 0.1
  - INP (Interaction to Next Paint) < 200ms
- **Code Splitting**: Dynamic imports, React.lazy, route-based splitting
- **Image Optimization**: next/image, srcset, lazy loading, WebP/AVIF
- **Caching Strategy**: TanStack Query, SWR, Service Workers
- **Bundle Analysis**: webpack-bundle-analyzer, source-map-explorer
- **Memory Management**: Detecting memory leaks, cleanup useEffect
- **Render Optimization**: useMemo, useCallback, React.memo đúng cách
- **Network Optimization**: Prefetching, preloading, resource hints

**Checklist khi review code**:
- [ ] Không có unnecessary re-renders
- [ ] Images có kích thước phù hợp
- [ ] Fonts được preload
- [ ] Third-party scripts được defer/async
- [ ] Critical CSS được inline

---

### 3. ♿ `accessibility-guarantor` (Chuyên gia Tiếp cận - A11y)
**Độ ưu tiên**: 🟡 Trung bình  
**Tiêu chuẩn**: WCAG 2.1 AA

**Nội dung cần bao gồm**:
- **Semantic HTML**: Sử dụng đúng thẻ (header, nav, main, article, aside, footer)
- **Keyboard Navigation**: Focus management, focus trap, skip links
- **ARIA Attributes**: aria-label, aria-describedby, aria-live, roles
- **Color Contrast**: Tối thiểu 4.5:1 cho text thường, 3:1 cho text lớn
- **Screen Reader Testing**: VoiceOver (Mac), NVDA (Windows)
- **Form Accessibility**: Labels, error messages, required fields
- **Media Accessibility**: Alt text, captions, transcripts
- **Motion Sensitivity**: prefers-reduced-motion

**Tools**:
- axe DevTools
- Lighthouse Accessibility
- eslint-plugin-jsx-a11y
- pa11y

---

### 4. 📐 `design-system-architect` (Kiến trúc sư Hệ thống Thiết kế)
**Độ ưu tiên**: 🟡 Trung bình  
**Thư viện liên quan**: shadcn/ui, Radix UI, Storybook, CVA (class-variance-authority)

**Nội dung cần bao gồm**:
- **Design Tokens**:
  - Colors (với dark mode support)
  - Typography scale
  - Spacing scale (4px base unit)
  - Border radius, shadows
  - Z-index layers
- **Component Architecture**:
  - Compound components pattern
  - Render props vs hooks
  - Controlled vs uncontrolled components
  - Prop forwarding và ref forwarding
- **Storybook Best Practices**:
  - Writing stories cho mọi component state
  - Docs addon cho documentation
  - Chromatic cho visual regression testing
- **Extending UI Libraries**:
  - Cách customize shadcn/ui components
  - Theming với CSS variables
  - Overriding default styles safely

**Folder Structure**:
```
components/
├── ui/           # Primitive components (Button, Input, Card)
├── patterns/     # Composed components (DataTable, FormField)
├── layouts/      # Layout components (PageLayout, Sidebar)
└── features/     # Feature-specific components
```

---

### 5. 🧪 `testing-frontend-pro` (Bậc thầy Kiểm thử)
**Độ ưu tiên**: 🟡 Trung bình  
**Thư viện liên quan**: Vitest, @testing-library/react, Playwright, MSW

**Nội dung cần bao gồm**:
- **Unit Testing với Vitest**:
  - Testing hooks with renderHook
  - Mocking modules và dependencies
  - Snapshot testing (khi nào nên/không nên dùng)
- **Integration Testing với Testing Library**:
  - Testing user interactions
  - Queries: getBy, queryBy, findBy (async)
  - userEvent vs fireEvent
  - Testing forms và validation
- **E2E Testing với Playwright**:
  - Page Object Model
  - Cross-browser testing
  - Visual comparison testing
  - Network mocking và interception
- **MSW (Mock Service Worker)**:
  - Request handlers
  - Response delays và errors
  - Testing loading/error states
- **Testing Patterns**:
  - Arrange-Act-Assert
  - Testing accessibility
  - Testing responsive behavior

**Coverage Goals**:
- Unit: > 80%
- Integration: Critical user flows
- E2E: Happy paths + key error scenarios

---

### 6. 🛡️ `web-security-frontend` (Lá chắn Bảo mật Front-end)
**Độ ưu tiên**: 🟠 Khá cao  
**Tham khảo**: OWASP Top 10

**Nội dung cần bao gồm**:
- **XSS Prevention**:
  - Sanitizing user input
  - DOMPurify cho rich text
  - React's built-in XSS protection
  - dangerouslySetInnerHTML pitfalls
- **CSRF Protection**:
  - CSRF tokens
  - SameSite cookies
  - Double submit cookie pattern
- **Content Security Policy (CSP)**:
  - Cấu hình CSP headers
  - Inline scripts và styles
  - Nonce-based CSP
- **Authentication Best Practices**:
  - JWT storage (localStorage vs httpOnly cookies)
  - Token refresh strategies
  - OAuth 2.0 / OIDC flows
  - Session management
- **Secure Communication**:
  - HTTPS everywhere
  - Certificate pinning (mobile)
  - HSTS headers
- **Dependency Security**:
  - npm audit
  - Snyk, Dependabot
  - Lock file importance

**Checklist**:
- [ ] Không lưu sensitive data trong localStorage
- [ ] API keys không hardcode trong frontend
- [ ] Forms có CSRF protection
- [ ] External links có rel="noopener noreferrer"

---

### 7. 📱 `responsive-mastery` (Bậc thầy Đa thiết bị)
**Độ ưu tiên**: 🟡 Trung bình  
**Approach**: Mobile-first

**Nội dung cần bao gồm**:
- **Breakpoint Strategy**:
  - Mobile: 320px - 480px
  - Tablet: 481px - 768px
  - Desktop: 769px - 1024px
  - Large: 1025px+
- **CSS Techniques**:
  - Container queries
  - clamp() cho fluid typography
  - aspect-ratio
  - min(), max(), clamp() functions
- **Mobile-specific Issues**:
  - 100vh problem (iOS Safari)
  - Safe area insets (notch)
  - Viewport units (dvh, svh, lvh)
  - Orientation change handling
- **Touch Optimization**:
  - Touch target size (44x44px minimum)
  - Touch vs click events
  - Gesture handling (swipe, pinch)
  - Hover states on touch devices
- **Performance on Mobile**:
  - Reduced motion preferences
  - Network-aware loading (Save-Data header)
  - Offline support basics
- **Testing**:
  - Device mode in DevTools
  - Real device testing
  - BrowserStack/LambdaTest

---

### 8. � `websocket-realtime-mastery` (Bậc thầy Realtime)
**Độ ưu tiên**: 🟠 Khá cao  
**Thư viện liên quan**: Socket.IO, Pusher, Ably, native WebSocket API, TanStack Query (for realtime)

**Nội dung cần bao gồm**:
- **WebSocket Fundamentals**:
  - WebSocket vs HTTP: Khi nào dùng gì
  - Connection lifecycle (open, message, error, close)
  - Heartbeat/Ping-pong để giữ kết nối
  - Binary data vs Text data
- **Socket.IO Best Practices**:
  - Namespaces và Rooms
  - Event-based communication patterns
  - Auto-reconnection strategies
  - Fallback to polling khi WebSocket không khả dụng
  - Scaling với Redis adapter
- **State Management với Realtime**:
  - Optimistic updates
  - Conflict resolution (last-write-wins, merge strategies)
  - Syncing local state với server state
  - TanStack Query với WebSocket invalidation
- **Common Use Cases**:
  - Live chat / Messaging
  - Real-time notifications
  - Collaborative editing (như Google Docs)
  - Live dashboards / Data streaming
  - Multiplayer games / Presence indicators
  - Live cursors / Typing indicators
- **Error Handling & Resilience**:
  - Exponential backoff for reconnection
  - Offline queue (lưu messages khi mất kết nối)
  - Connection state UI feedback
  - Graceful degradation
- **Security**:
  - Authentication over WebSocket (JWT in handshake)
  - Authorization cho rooms/channels
  - Rate limiting
  - Input validation (server-side)
- **Performance**:
  - Message batching
  - Compression (permessage-deflate)
  - Connection pooling
  - Lazy subscription (chỉ subscribe khi cần)
- **Testing**:
  - Mocking WebSocket connections
  - Testing reconnection scenarios
  - Load testing với Artillery hoặc k6

**Patterns quan trọng**:
```javascript
// Reconnection với exponential backoff
const reconnect = (attempt = 1) => {
  const delay = Math.min(1000 * 2 ** attempt, 30000);
  setTimeout(() => connect(), delay);
};

// Optimistic update pattern
const sendMessage = (message) => {
  // 1. Update UI immediately (optimistic)
  addMessageToUI(message, { pending: true });
  
  // 2. Send to server
  socket.emit('message', message, (ack) => {
    if (ack.error) {
      // 3a. Rollback on error
      removeMessageFromUI(message.id);
      showError(ack.error);
    } else {
      // 3b. Confirm on success
      updateMessageStatus(message.id, { pending: false });
    }
  });
};
```

**Checklist**:
- [ ] Có UI indicator cho connection status
- [ ] Xử lý reconnection tự động
- [ ] Có offline queue cho critical messages
- [ ] Authentication được thực hiện trước khi join rooms
- [ ] Cleanup subscriptions khi component unmount

---

## �🚀 Lộ trình cài đặt đề xuất

### Phase 1: Foundation (Tuần 1-2)
- [ ] `framer-motion-magic` - Tạo ấn tượng mạnh với animations
- [ ] `performance-precision` - Đảm bảo tốc độ chuyên nghiệp

### Phase 2: Quality (Tuần 3-4)
- [ ] `testing-frontend-pro` - Đảm bảo độ tin cậy
- [ ] `web-security-frontend` - Bảo vệ ứng dụng

### Phase 3: Polish (Tuần 5-6)
- [ ] `accessibility-guarantor` - Mở rộng đối tượng người dùng
- [ ] `design-system-architect` - Tối ưu quy trình phát triển

### Phase 4: Mastery (Tuần 7-8)
- [ ] `responsive-mastery` - Hoàn thiện trải nghiệm đa thiết bị
- [ ] `websocket-realtime-mastery` - Xây dựng ứng dụng realtime chuyên nghiệp

---

## 📌 Ghi chú

- Mỗi skill khi cài đặt sẽ tạo folder trong `skills/` với file `SKILL.md` chứa hướng dẫn chi tiết
- Có thể bổ sung thêm các examples và scripts vào từng skill folder
- Định kỳ review và update nội dung các skills theo xu hướng công nghệ mới

---

*Được tạo bởi Mine - Your Vibe Coding Partner* 💖
