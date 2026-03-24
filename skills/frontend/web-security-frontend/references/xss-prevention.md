# 🛡️ XSS Prevention Guide

## Table of Contents
1. [Types of XSS](#types-of-xss)
2. [Prevention Techniques](#prevention-techniques)
3. [DOMPurify Usage](#dompurify-usage)
4. [Framework-Specific Protection](#framework-specific-protection)
5. [URL Sanitization](#url-sanitization)
6. [Testing for XSS](#testing-for-xss)

---

## Types of XSS

### 1. Reflected XSS
Script được gửi qua URL/request và phản hồi lại ngay trong response.

```javascript
// URL: https://example.com/search?q=<script>alert('XSS')</script>

// ❌ Server phản hồi trực tiếp
res.send(`Search results for: ${req.query.q}`);

// ✅ Encode output
import { encode } from 'html-entities';
res.send(`Search results for: ${encode(req.query.q)}`);
```

### 2. Stored XSS
Script được lưu trong database và hiển thị cho các users khác.

```javascript
// ❌ Render comment trực tiếp từ DB
<div dangerouslySetInnerHTML={{ __html: comment.content }} />

// ✅ Sanitize trước khi render
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(comment.content) }} />
```

### 3. DOM-based XSS
Script được inject qua DOM manipulation phía client.

```javascript
// ❌ Directly inserting user input into DOM
document.getElementById('output').innerHTML = location.hash.slice(1);

// ✅ Use textContent for plain text
document.getElementById('output').textContent = location.hash.slice(1);
```

---

## Prevention Techniques

### 1. Output Encoding
Encode data based on context:

```javascript
// HTML Context
import { encode } from 'html-entities';
const safe = encode(userInput);
// <script> becomes &lt;script&gt;

// JavaScript Context
const safe = JSON.stringify(userInput);

// URL Context
const safe = encodeURIComponent(userInput);

// CSS Context
const safe = CSS.escape(userInput);
```

### 2. Input Validation
Whitelist approach - chỉ cho phép những gì hợp lệ:

```javascript
// Validate email format
const isValidEmail = (email) => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return re.test(email);
};

// Validate numeric input
const isValidAge = (age) => {
  const num = parseInt(age, 10);
  return !isNaN(num) && num >= 0 && num <= 150;
};

// Validate allowed characters
const isValidUsername = (username) => {
  return /^[a-zA-Z0-9_-]{3,20}$/.test(username);
};
```

### 3. Content Security Policy
Ngăn inline scripts execution:

```http
Content-Security-Policy: script-src 'self'; object-src 'none';
```

---

## DOMPurify Usage

### Installation
```bash
npm install dompurify
# For TypeScript
npm install --save-dev @types/dompurify
```

### Basic Usage
```javascript
import DOMPurify from 'dompurify';

// Sanitize HTML
const clean = DOMPurify.sanitize(dirtyHTML);

// React usage
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(content) }} />
```

### Advanced Configuration
```javascript
// Allow only specific tags
const clean = DOMPurify.sanitize(dirty, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p', 'br'],
  ALLOWED_ATTR: ['href', 'title', 'target'],
});

// Remove all HTML, keep text only
const textOnly = DOMPurify.sanitize(dirty, {
  ALLOWED_TAGS: [],
  ALLOWED_ATTR: [],
});

// Allow data attributes
const withData = DOMPurify.sanitize(dirty, {
  ADD_ATTR: ['data-id', 'data-type'],
});

// Block dangerous protocols
const safeLinks = DOMPurify.sanitize(dirty, {
  ALLOWED_URI_REGEXP: /^(?:(?:https?|mailto):|[^a-z]|[a-z+.-]+(?:[^a-z+.-:]|$))/i,
});
```

### Custom Hooks
```javascript
// Add hook to open links in new tab
DOMPurify.addHook('afterSanitizeAttributes', (node) => {
  if (node.tagName === 'A') {
    node.setAttribute('target', '_blank');
    node.setAttribute('rel', 'noopener noreferrer');
  }
});

// Remove specific attributes
DOMPurify.addHook('uponSanitizeAttribute', (node, data) => {
  if (data.attrName === 'style') {
    data.keepAttr = false;
  }
});
```

---

## Framework-Specific Protection

### React
```jsx
// ✅ Auto-escaped (safe)
<div>{userInput}</div>
<span className={userInput}>...</span>

// ⚠️ DANGEROUS - Only use with sanitized content
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />

// ❌ AVOID - Directly setting innerHTML
useEffect(() => {
  ref.current.innerHTML = userInput; // XSS vulnerability!
}, [userInput]);
```

### Vue.js
```vue
<!-- ✅ Auto-escaped (safe) -->
<div>{{ userInput }}</div>
<span :class="userInput">...</span>

<!-- ⚠️ DANGEROUS - Only use with sanitized content -->
<div v-html="sanitizedContent"></div>

<script setup>
import DOMPurify from 'dompurify';
const sanitizedContent = computed(() => 
  DOMPurify.sanitize(props.rawHtml)
);
</script>
```

### Angular
```typescript
// ✅ Auto-escaped (safe)
@Component({
  template: `<div>{{ userInput }}</div>`
})

// ⚠️ Bypass sanitization carefully
import { DomSanitizer, SafeHtml } from '@angular/platform-browser';

@Component({
  template: `<div [innerHTML]="safeHtml"></div>`
})
export class MyComponent {
  safeHtml: SafeHtml;
  
  constructor(private sanitizer: DomSanitizer) {
    // Only after sanitizing with DOMPurify
    const clean = DOMPurify.sanitize(rawHtml);
    this.safeHtml = this.sanitizer.bypassSecurityTrustHtml(clean);
  }
}
```

---

## URL Sanitization

### Prevent javascript: URLs
```javascript
const sanitizeUrl = (url) => {
  if (!url) return '';
  
  // Parse URL
  try {
    const parsed = new URL(url, window.location.origin);
    
    // Only allow safe protocols
    const safeProtocols = ['http:', 'https:', 'mailto:', 'tel:'];
    if (!safeProtocols.includes(parsed.protocol)) {
      return '';
    }
    
    return parsed.href;
  } catch {
    return '';
  }
};

// Usage in React
<a href={sanitizeUrl(userProvidedUrl)}>Link</a>
```

### Using a Library
```bash
npm install @braintree/sanitize-url
```

```javascript
import { sanitizeUrl } from '@braintree/sanitize-url';

const safeUrl = sanitizeUrl(userInput);
// 'javascript:alert(1)' → 'about:blank'
// 'https://example.com' → 'https://example.com'
```

---

## Testing for XSS

### Common Payloads
```javascript
// Test strings to try in input fields
const xssPayloads = [
  '<script>alert("XSS")</script>',
  '<img src=x onerror=alert("XSS")>',
  '<svg onload=alert("XSS")>',
  '"><script>alert("XSS")</script>',
  "'-alert('XSS')-'",
  '<a href="javascript:alert(\'XSS\')">click</a>',
  '<div onmouseover="alert(\'XSS\')">hover</div>',
];
```

### Automated Testing
```javascript
// Using OWASP ZAP or Burp Suite for automated scanning
// Integration with CI/CD

// Example: npm script for security testing
// package.json
{
  "scripts": {
    "security:test": "npm audit && snyk test"
  }
}
```

### ESLint Rules
```javascript
// .eslintrc.js
module.exports = {
  plugins: ['security'],
  rules: {
    'security/detect-object-injection': 'warn',
    'security/detect-non-literal-regexp': 'warn',
    'security/detect-unsafe-regex': 'error',
    'react/no-danger': 'warn', // Warn on dangerouslySetInnerHTML
  },
};
```

---

## Summary Checklist

- [ ] Never use `innerHTML` with user input
- [ ] Sanitize with DOMPurify before `dangerouslySetInnerHTML`
- [ ] Validate and encode all user inputs
- [ ] Implement strict CSP headers
- [ ] Sanitize URLs before using in `href`
- [ ] Use framework's auto-escaping features
- [ ] Add ESLint security rules
- [ ] Test with common XSS payloads
