# 🛡️ CSP & Security Headers Guide

## Content Security Policy (CSP)

CSP header kiểm soát nguồn tài nguyên được phép load, ngăn XSS attacks.

### Essential Directives

| Directive | Controls | Example |
|-----------|----------|---------|
| `default-src` | Fallback | `'self'` |
| `script-src` | JS | `'self' 'nonce-abc'` |
| `style-src` | CSS | `'self' 'unsafe-inline'` |
| `img-src` | Images | `'self' data: https:` |
| `connect-src` | fetch/XHR | `'self' https://api.com` |
| `frame-src` | iframes | `'none'` |

### Recommended CSP
```
Content-Security-Policy: 
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://api.yoursite.com;
  frame-src 'none';
  object-src 'none';
  base-uri 'self';
  form-action 'self';
```

### Nonce-based CSP
```javascript
// Server generates nonce per request
const nonce = crypto.randomBytes(16).toString('base64');
res.setHeader('Content-Security-Policy', 
  `script-src 'self' 'nonce-${nonce}';`
);

// HTML uses nonce
<script nonce="${nonce}">console.log('allowed')</script>
```

---

## Other Security Headers

```
# Prevent MIME sniffing
X-Content-Type-Options: nosniff

# Block iframe embedding (clickjacking)
X-Frame-Options: DENY

# Control Referer info
Referrer-Policy: strict-origin-when-cross-origin

# Disable browser features
Permissions-Policy: camera=(), microphone=()

# Force HTTPS
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

---

## Next.js Implementation

```javascript
// next.config.js
const securityHeaders = [
  { key: 'Content-Security-Policy', value: "default-src 'self'; script-src 'self';" },
  { key: 'X-Frame-Options', value: 'DENY' },
  { key: 'X-Content-Type-Options', value: 'nosniff' },
  { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
  { key: 'Permissions-Policy', value: 'camera=(), microphone=()' },
];

module.exports = {
  async headers() {
    return [{ source: '/:path*', headers: securityHeaders }];
  },
};
```

## Express.js with Helmet
```javascript
import helmet from 'helmet';
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
    },
  },
}));
```

---

## Testing Tools
- CSP Evaluator: https://csp-evaluator.withgoogle.com/
- Security Headers: https://securityheaders.com/
- Mozilla Observatory: https://observatory.mozilla.org/
