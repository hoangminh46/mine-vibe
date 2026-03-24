# 🔐 Authentication Best Practices Guide

## Table of Contents
1. [Token Storage](#token-storage)
2. [JWT Best Practices](#jwt-best-practices)
3. [OAuth 2.0 / OIDC](#oauth-20--oidc)
4. [Session Management](#session-management)
5. [Password Security](#password-security)

---

## Token Storage

### ❌ localStorage - AVOID for Auth Tokens
```javascript
// VULNERABLE to XSS - Any script can access
localStorage.setItem('token', jwtToken);
const token = localStorage.getItem('token');
```

### ✅ HttpOnly Cookies - RECOMMENDED
```javascript
// Server sets cookie (not accessible via JS)
Set-Cookie: auth_token=abc123; 
  HttpOnly; 
  Secure; 
  SameSite=Strict;
  Path=/;
  Max-Age=3600;

// Frontend: Token sent automatically with requests
fetch('/api/protected', { credentials: 'include' });
```

### Memory + Refresh Token Pattern
```javascript
// Store access token in memory (short-lived)
let accessToken = null;

// Refresh token in httpOnly cookie
const refreshAuth = async () => {
  const res = await fetch('/api/refresh', { credentials: 'include' });
  const { token } = await res.json();
  accessToken = token;
  return token;
};

// Use in requests
const apiCall = async (url) => {
  if (!accessToken) await refreshAuth();
  return fetch(url, {
    headers: { Authorization: `Bearer ${accessToken}` }
  });
};
```

---

## JWT Best Practices

### Token Configuration
```javascript
// ✅ Short-lived access tokens (15-60 minutes)
const accessToken = jwt.sign(payload, secret, { expiresIn: '15m' });

// ✅ Longer refresh tokens (7-30 days)
const refreshToken = jwt.sign({ userId }, secret, { expiresIn: '7d' });
```

### Required Claims
```javascript
const payload = {
  sub: userId,           // Subject (user ID)
  iat: Date.now(),       // Issued at
  exp: Date.now() + 900, // Expiration (15 min)
  iss: 'your-app',       // Issuer
  aud: 'your-app',       // Audience
};
```

### Token Refresh Flow
```javascript
// Frontend: Auto-refresh before expiry
const scheduleRefresh = (expiresIn) => {
  const refreshTime = (expiresIn - 60) * 1000; // 1 min before expiry
  setTimeout(refreshAuth, refreshTime);
};

// Backend: Refresh endpoint
app.post('/api/refresh', (req, res) => {
  const refreshToken = req.cookies.refresh_token;
  
  try {
    const decoded = jwt.verify(refreshToken, REFRESH_SECRET);
    
    // Optional: Rotate refresh token
    const newRefreshToken = generateRefreshToken(decoded.userId);
    const newAccessToken = generateAccessToken(decoded.userId);
    
    res.cookie('refresh_token', newRefreshToken, {
      httpOnly: true,
      secure: true,
      sameSite: 'strict',
    });
    
    res.json({ token: newAccessToken });
  } catch {
    res.status(401).json({ error: 'Invalid refresh token' });
  }
});
```

---

## OAuth 2.0 / OIDC

### Authorization Code Flow (Recommended for Web)
```javascript
// Step 1: Redirect to provider
const authUrl = new URL('https://provider.com/authorize');
authUrl.searchParams.set('client_id', CLIENT_ID);
authUrl.searchParams.set('redirect_uri', REDIRECT_URI);
authUrl.searchParams.set('response_type', 'code');
authUrl.searchParams.set('scope', 'openid profile email');
authUrl.searchParams.set('state', generateState()); // CSRF protection
authUrl.searchParams.set('code_challenge', codeChallenge); // PKCE
authUrl.searchParams.set('code_challenge_method', 'S256');

window.location.href = authUrl.toString();

// Step 2: Handle callback (backend)
app.get('/callback', async (req, res) => {
  const { code, state } = req.query;
  
  // Verify state matches
  if (state !== req.session.oauthState) {
    return res.status(403).send('Invalid state');
  }
  
  // Exchange code for tokens
  const tokenResponse = await fetch('https://provider.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: REDIRECT_URI,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
      code_verifier: req.session.codeVerifier, // PKCE
    }),
  });
  
  const tokens = await tokenResponse.json();
  // Create session, set cookies, redirect
});
```

### PKCE (Proof Key for Code Exchange)
```javascript
// Generate code verifier and challenge
const generatePKCE = async () => {
  const verifier = crypto.randomBytes(32).toString('base64url');
  
  const encoder = new TextEncoder();
  const data = encoder.encode(verifier);
  const hash = await crypto.subtle.digest('SHA-256', data);
  const challenge = btoa(String.fromCharCode(...new Uint8Array(hash)))
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
  
  return { verifier, challenge };
};
```

---

## Session Management

### Secure Session Configuration
```javascript
import session from 'express-session';
import RedisStore from 'connect-redis';

app.use(session({
  store: new RedisStore({ client: redisClient }),
  name: 'sessionId', // Custom name (not 'connect.sid')
  secret: process.env.SESSION_SECRET,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    secure: process.env.NODE_ENV === 'production',
    sameSite: 'strict',
    maxAge: 1000 * 60 * 60 * 24, // 24 hours
  },
}));
```

### Session Invalidation
```javascript
// Logout: Destroy session
app.post('/logout', (req, res) => {
  req.session.destroy((err) => {
    res.clearCookie('sessionId');
    res.json({ success: true });
  });
});

// Logout everywhere: Invalidate all user sessions
app.post('/logout-all', async (req, res) => {
  const userId = req.session.userId;
  await redisClient.del(`user:${userId}:sessions:*`);
  res.json({ success: true });
});
```

### Session Fixation Prevention
```javascript
// Regenerate session ID after login
app.post('/login', async (req, res) => {
  const user = await authenticateUser(req.body);
  
  if (user) {
    // Regenerate session to prevent fixation
    req.session.regenerate((err) => {
      req.session.userId = user.id;
      res.json({ success: true });
    });
  }
});
```

---

## Password Security

### Password Requirements
```javascript
const validatePassword = (password) => {
  const errors = [];
  
  if (password.length < 12) errors.push('At least 12 characters');
  if (!/[A-Z]/.test(password)) errors.push('One uppercase letter');
  if (!/[a-z]/.test(password)) errors.push('One lowercase letter');
  if (!/[0-9]/.test(password)) errors.push('One number');
  if (!/[^A-Za-z0-9]/.test(password)) errors.push('One special character');
  
  return { valid: errors.length === 0, errors };
};
```

### Password Hashing (Backend)
```javascript
import bcrypt from 'bcrypt';

// Hash password before storing
const hashPassword = async (password) => {
  const saltRounds = 12;
  return bcrypt.hash(password, saltRounds);
};

// Verify password on login
const verifyPassword = async (password, hash) => {
  return bcrypt.compare(password, hash);
};
```

### Rate Limiting Login Attempts
```javascript
import rateLimit from 'express-rate-limit';

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: { error: 'Too many login attempts. Try again later.' },
  standardHeaders: true,
});

app.post('/login', loginLimiter, loginHandler);
```

---

## Summary Checklist

- [ ] Store auth tokens in httpOnly cookies, not localStorage
- [ ] Use short-lived access tokens (15-60 min)
- [ ] Implement refresh token rotation
- [ ] Use HTTPS for all auth endpoints
- [ ] Implement PKCE for OAuth flows
- [ ] Regenerate session after login
- [ ] Rate limit login attempts
- [ ] Hash passwords with bcrypt (cost 12+)
- [ ] Provide "logout everywhere" functionality
