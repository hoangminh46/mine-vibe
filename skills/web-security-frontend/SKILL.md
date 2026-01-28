---
name: web-security-frontend
description: Comprehensive frontend security practices covering XSS prevention, CSRF protection, Content Security Policy (CSP), secure authentication flows, and dependency security. Use when (1) implementing authentication/authorization, (2) handling user input that renders as HTML, (3) configuring security headers, (4) auditing frontend code for vulnerabilities, (5) storing sensitive data (tokens, cookies), or (6) protecting against common web attacks like XSS, CSRF, clickjacking.
---

# 🛡️ Web Security Frontend

Skill này giúp bảo vệ ứng dụng frontend khỏi các lỗ hổng bảo mật phổ biến theo chuẩn **OWASP Top 10**.

## 📚 Quick Navigation

| Topic | Reference File | Use When |
|-------|---------------|----------|
| XSS Prevention | [references/xss-prevention.md](references/xss-prevention.md) | Xử lý user input, render HTML |
| CSRF Protection | [references/csrf-protection.md](references/csrf-protection.md) | Forms, state-changing requests |
| CSP & Headers | [references/csp-headers.md](references/csp-headers.md) | Cấu hình security headers |
| Auth Best Practices | [references/auth-best-practices.md](references/auth-best-practices.md) | Xây dựng auth flow |

---

## 🎯 Core Security Principles

### 1. Defense in Depth
Áp dụng nhiều lớp bảo vệ - không dựa vào một biện pháp duy nhất.

### 2. Least Privilege
Chỉ cấp quyền tối thiểu cần thiết cho user và code.

### 3. Trust No Input
Mọi input từ user, URL, cookies đều phải được validate và sanitize.

### 4. Fail Securely
Khi có lỗi, hệ thống phải fail về trạng thái an toàn (deny access).

---

## ⚡ Quick Reference: Common Vulnerabilities

### XSS (Cross-Site Scripting)
```javascript
// ❌ NGUY HIỂM - Để XSS xảy ra
element.innerHTML = userInput;
<div dangerouslySetInnerHTML={{ __html: userInput }} />

// ✅ AN TOÀN - React auto-escapes
<div>{userInput}</div>

// ✅ AN TOÀN - Nếu cần render HTML, sanitize trước
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(userInput) }} />
```

### CSRF (Cross-Site Request Forgery)
```javascript
// ✅ Sử dụng CSRF token cho mọi state-changing request
const response = await fetch('/api/update', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-CSRF-Token': getCsrfToken(), // Token từ server
  },
  credentials: 'include', // Gửi cookies
  body: JSON.stringify(data),
});
```

### Secure Cookie Configuration
```javascript
// ✅ Cấu hình cookie an toàn (server-side)
Set-Cookie: token=abc123; 
  HttpOnly;           // Không access được từ JS
  Secure;             // Chỉ gửi qua HTTPS  
  SameSite=Strict;    // Chống CSRF
  Path=/;
  Max-Age=3600;
```

---

## 🔐 Authentication Checklist

- [ ] **Token Storage**: Dùng `httpOnly` cookies thay vì `localStorage`
- [ ] **Short-lived Tokens**: Access token ngắn hạn (15-60 phút)
- [ ] **Refresh Token Rotation**: Rotate refresh token mỗi lần sử dụng
- [ ] **Logout Everywhere**: Hỗ trợ invalidate tất cả sessions
- [ ] **HTTPS Only**: Tất cả auth endpoints chỉ qua HTTPS
- [ ] **Rate Limiting**: Giới hạn login attempts

---

## 🛡️ Security Headers Checklist

```
# Cấu hình recommended cho Next.js/Nginx
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self';
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
Strict-Transport-Security: max-age=31536000; includeSubDomains
```

---

## 🔍 Security Audit Checklist

### Input Handling
- [ ] Tất cả user input được validate
- [ ] Rich text được sanitize với DOMPurify
- [ ] URL được validate protocol (http/https only)
- [ ] File uploads được kiểm tra type và size

### Data Protection  
- [ ] Không hardcode API keys, secrets
- [ ] Sensitive data không lưu localStorage
- [ ] Credentials không log ra console
- [ ] Production không có debug/test data

### Network Security
- [ ] HTTPS everywhere
- [ ] External links có `rel="noopener noreferrer"`
- [ ] API endpoints validate origin
- [ ] CORS cấu hình chặt chẽ

### Dependencies
- [ ] Chạy `npm audit` định kỳ
- [ ] Lock file được commit
- [ ] Dependencies được update thường xuyên
- [ ] Không sử dụng deprecated packages

---

## 🧪 Testing Security

### Tools
- **npm audit**: Kiểm tra vulnerabilities trong dependencies
- **Snyk**: CI/CD integration cho security scanning
- **OWASP ZAP**: Automated security testing
- **Lighthouse**: Security audit trong DevTools

### Manual Testing
```bash
# Check dependencies
npm audit

# Fix automatically where possible
npm audit fix

# Check for more details
npm audit --json
```

---

## 📖 Framework-Specific Guides

### React
- Auto-escapes JSX expressions `{variable}`
- Tránh `dangerouslySetInnerHTML` 
- Sử dụng DOMPurify khi cần render HTML
- ESLint plugin: `eslint-plugin-react-security`

### Vue.js
- Auto-escapes template expressions `{{ variable }}`
- Tránh `v-html` với untrusted content
- Sanitize nếu phải dùng `v-html`

### Angular  
- Built-in sanitization với `DomSanitizer`
- Auto-escapes template bindings
- Route guards cho protected routes

---

## 🚨 Common Mistakes to Avoid

### 1. Storing Tokens in localStorage
```javascript
// ❌ Dễ bị XSS attack đánh cắp
localStorage.setItem('token', jwtToken);

// ✅ Sử dụng httpOnly cookie (cần server config)
// Token được tự động gửi với requests
```

### 2. Trusting Client-Side Validation
```javascript
// ❌ Chỉ validate client-side
if (email.includes('@')) { submit(); }

// ✅ Validate BOTH client và server
// Client: UX feedback nhanh
// Server: Security enforcement
```

### 3. Exposing Sensitive Data in Errors
```javascript
// ❌ Leak thông tin nhạy cảm
console.error('Database error:', error);
alert(`Error: ${error.stack}`);

// ✅ Log server-side, show generic message
console.error('[Server]', error); // Only in dev
showToast('Something went wrong. Please try again.');
```

### 4. Missing CORS Configuration
```javascript
// ❌ Cho phép tất cả origins
Access-Control-Allow-Origin: *

// ✅ Chỉ allow specific origins
Access-Control-Allow-Origin: https://myapp.com
Access-Control-Allow-Credentials: true
```

---

## 📚 Deep Dive References

Đọc các file trong `references/` để hiểu chi tiết:

1. **[xss-prevention.md](references/xss-prevention.md)** - XSS types, prevention techniques, DOMPurify usage
2. **[csrf-protection.md](references/csrf-protection.md)** - CSRF tokens, SameSite cookies, double submit pattern
3. **[csp-headers.md](references/csp-headers.md)** - CSP directives, nonce-based CSP, header configurations
4. **[auth-best-practices.md](references/auth-best-practices.md)** - JWT handling, OAuth flows, session management
