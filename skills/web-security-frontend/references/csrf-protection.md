# 🛡️ CSRF Protection Guide

## Table of Contents
1. [Understanding CSRF](#understanding-csrf)
2. [Prevention Methods](#prevention-methods)
3. [SameSite Cookies](#samesite-cookies)
4. [CSRF Tokens Implementation](#csrf-tokens-implementation)
5. [Framework Integration](#framework-integration)
6. [Testing CSRF Protection](#testing-csrf-protection)

---

## Understanding CSRF

### What is CSRF?
Cross-Site Request Forgery (CSRF) tricks authenticated users vào thực hiện actions không mong muốn trên ứng dụng web mà họ đang đăng nhập.

### Attack Flow
```
1. User logs into bank.com (session cookie set)
2. User visits malicious.com
3. malicious.com contains: <form action="bank.com/transfer" method="POST">
4. Form auto-submits with user's session cookie
5. Unauthorized transfer happens
```

### Vulnerable Patterns
```html
<!-- ❌ Form without CSRF protection -->
<form action="/api/transfer" method="POST">
  <input name="amount" value="1000" />
  <input name="to" value="attacker" />
  <button type="submit">Transfer</button>
</form>

<!-- ❌ State-changing GET request -->
<a href="/api/delete?id=123">Delete Item</a>
<img src="/api/logout" /> <!-- Logs user out! -->
```

---

## Prevention Methods

### 1. CSRF Tokens (Synchronizer Token Pattern)
Server generates unique token, client sends it back with each request.

```javascript
// Server: Generate and store token
const csrfToken = crypto.randomBytes(32).toString('hex');
req.session.csrfToken = csrfToken;

// Server: Set token in response
res.cookie('XSRF-TOKEN', csrfToken);
// OR include in HTML
res.render('form', { csrfToken });

// Client: Include token in requests
fetch('/api/action', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': getCsrfTokenFromCookie(),
  },
  credentials: 'include',
  body: JSON.stringify(data),
});
```

### 2. Double Submit Cookie
Token in both cookie AND request body/header.

```javascript
// Server sets token cookie
Set-Cookie: csrf_token=random123; Path=/; Secure; SameSite=Strict

// Client reads cookie and sends in header
const csrfToken = document.cookie
  .split('; ')
  .find(row => row.startsWith('csrf_token='))
  ?.split('=')[1];

fetch('/api/action', {
  method: 'POST',
  headers: {
    'X-CSRF-Token': csrfToken,
  },
  credentials: 'include',
  body: JSON.stringify(data),
});

// Server validates: cookie value === header value
```

### 3. Same-Origin Verification
Check Origin and Referer headers.

```javascript
// Server middleware
const validateOrigin = (req, res, next) => {
  const origin = req.headers.origin;
  const referer = req.headers.referer;
  const host = req.headers.host;
  
  const allowedOrigins = [
    `https://${host}`,
    `http://${host}`, // Only in development
  ];
  
  const requestOrigin = origin || (referer && new URL(referer).origin);
  
  if (!requestOrigin || !allowedOrigins.includes(requestOrigin)) {
    return res.status(403).json({ error: 'CSRF check failed' });
  }
  
  next();
};
```

---

## SameSite Cookies

### Cookie Attributes
```javascript
// ✅ Most secure for auth cookies
Set-Cookie: session=abc123; 
  HttpOnly;         // No JS access
  Secure;           // HTTPS only
  SameSite=Strict;  // Only same-site requests
  Path=/;
  Max-Age=3600;
```

### SameSite Values

| Value | Cross-site GET | Cross-site POST | Top-level Navigation |
|-------|---------------|-----------------|---------------------|
| `Strict` | ❌ | ❌ | ❌ |
| `Lax` | ✅ | ❌ | ✅ |
| `None` | ✅ | ✅ | ✅ |

```javascript
// Strict: Most secure, may break OAuth redirects
Set-Cookie: session=abc; SameSite=Strict; Secure

// Lax: Good balance, default in modern browsers
Set-Cookie: session=abc; SameSite=Lax; Secure

// None: Required for cross-site cookies (e.g., embedded content)
// MUST include Secure flag
Set-Cookie: session=abc; SameSite=None; Secure
```

### Recommended Configuration
```javascript
// Auth session cookie - Strict
Set-Cookie: session_id=abc123; HttpOnly; Secure; SameSite=Strict

// CSRF token cookie - Accessible to JS
Set-Cookie: csrf_token=xyz789; Secure; SameSite=Strict

// Preference cookie - Lax is fine
Set-Cookie: theme=dark; SameSite=Lax
```

---

## CSRF Tokens Implementation

### Express.js with csurf
```javascript
import csurf from 'csurf';
import cookieParser from 'cookie-parser';

const app = express();
app.use(cookieParser());
app.use(csurf({ cookie: true }));

// Provide token to client
app.get('/api/csrf-token', (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// Token validated automatically on POST, PUT, DELETE
app.post('/api/action', (req, res) => {
  // If token invalid, csurf throws error
  res.json({ success: true });
});

// Error handler
app.use((err, req, res, next) => {
  if (err.code === 'EBADCSRFTOKEN') {
    return res.status(403).json({ error: 'Invalid CSRF token' });
  }
  next(err);
});
```

### React Frontend
```jsx
// useCsrf hook
import { useState, useEffect } from 'react';

export const useCsrf = () => {
  const [token, setToken] = useState('');
  
  useEffect(() => {
    fetch('/api/csrf-token', { credentials: 'include' })
      .then(res => res.json())
      .then(data => setToken(data.csrfToken));
  }, []);
  
  return token;
};

// Usage in component
const MyForm = () => {
  const csrfToken = useCsrf();
  
  const handleSubmit = async (data) => {
    await fetch('/api/action', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      credentials: 'include',
      body: JSON.stringify(data),
    });
  };
  
  return (
    <form onSubmit={handleSubmit}>
      {/* Hidden input for non-JS fallback */}
      <input type="hidden" name="_csrf" value={csrfToken} />
      {/* ... */}
    </form>
  );
};
```

### Axios Interceptor
```javascript
import axios from 'axios';

// Automatically include CSRF token
axios.defaults.withCredentials = true;

axios.interceptors.request.use((config) => {
  // Read token from cookie
  const token = document.cookie
    .split('; ')
    .find(row => row.startsWith('XSRF-TOKEN='))
    ?.split('=')[1];
  
  if (token && ['post', 'put', 'delete', 'patch'].includes(config.method)) {
    config.headers['X-CSRF-Token'] = token;
  }
  
  return config;
});
```

---

## Framework Integration

### Next.js (App Router)
```typescript
// middleware.ts
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export function middleware(request: NextRequest) {
  // Skip for GET, HEAD, OPTIONS
  if (['GET', 'HEAD', 'OPTIONS'].includes(request.method)) {
    return NextResponse.next();
  }
  
  const csrfCookie = request.cookies.get('csrf_token')?.value;
  const csrfHeader = request.headers.get('x-csrf-token');
  
  if (!csrfCookie || !csrfHeader || csrfCookie !== csrfHeader) {
    return NextResponse.json(
      { error: 'Invalid CSRF token' },
      { status: 403 }
    );
  }
  
  return NextResponse.next();
}

export const config = {
  matcher: '/api/:path*',
};
```

### Angular HttpClient
```typescript
// Angular automatically includes CSRF for same-origin requests
// Configure XSRF token name
import { provideHttpClient, withXsrfConfiguration } from '@angular/common/http';

export const appConfig = {
  providers: [
    provideHttpClient(
      withXsrfConfiguration({
        cookieName: 'XSRF-TOKEN',
        headerName: 'X-XSRF-TOKEN',
      })
    ),
  ],
};
```

### Django + React
```python
# Django settings.py
CSRF_COOKIE_SAMESITE = 'Strict'
CSRF_COOKIE_SECURE = True
CSRF_TRUSTED_ORIGINS = ['https://your-frontend.com']
```

```javascript
// React: Read Django CSRF cookie
const getCsrfToken = () => {
  return document.cookie
    .split('; ')
    .find(row => row.startsWith('csrftoken='))
    ?.split('=')[1];
};

// Include in requests
fetch('/api/action', {
  method: 'POST',
  headers: {
    'X-CSRFToken': getCsrfToken(),
  },
  credentials: 'include',
});
```

---

## Testing CSRF Protection

### Manual Testing
```html
<!-- Create this HTML file and open in browser while logged in -->
<!DOCTYPE html>
<html>
<body>
  <h1>CSRF Test</h1>
  
  <!-- Test 1: Form without token -->
  <form action="https://target.com/api/action" method="POST">
    <input name="data" value="malicious" />
    <button type="submit">Submit</button>
  </form>
  
  <!-- Test 2: Auto-submit -->
  <form id="autoForm" action="https://target.com/api/action" method="POST">
    <input name="data" value="malicious" />
  </form>
  <script>document.getElementById('autoForm').submit();</script>
</body>
</html>
```

### Expected Results
- ✅ Request should be **rejected** with 403 Forbidden
- ❌ If request succeeds, CSRF protection is broken

### Automated Testing
```javascript
// Jest test example
describe('CSRF Protection', () => {
  it('should reject requests without CSRF token', async () => {
    const response = await fetch('/api/protected', {
      method: 'POST',
      credentials: 'include',
      body: JSON.stringify({ data: 'test' }),
    });
    
    expect(response.status).toBe(403);
  });
  
  it('should accept requests with valid CSRF token', async () => {
    // Get token first
    const tokenRes = await fetch('/api/csrf-token', { credentials: 'include' });
    const { csrfToken } = await tokenRes.json();
    
    const response = await fetch('/api/protected', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': csrfToken,
      },
      credentials: 'include',
      body: JSON.stringify({ data: 'test' }),
    });
    
    expect(response.status).toBe(200);
  });
});
```

---

## Summary Checklist

- [ ] Implement CSRF tokens for all state-changing operations
- [ ] Use `SameSite=Strict` or `SameSite=Lax` for auth cookies
- [ ] Never use GET for state-changing operations
- [ ] Include CSRF token in headers, not just body
- [ ] Validate Origin/Referer headers as additional layer
- [ ] Set `HttpOnly` and `Secure` flags on session cookies
- [ ] Test CSRF protection with manual and automated tests
- [ ] Use framework's built-in CSRF protection when available
