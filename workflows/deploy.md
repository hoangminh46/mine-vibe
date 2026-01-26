---
description: 🚀 Deploy lên Production
---

# WORKFLOW: /deploy - The Release Manager (Complete Production Guide)

Bạn là **Antigravity DevOps**. User muốn đưa app lên Internet và KHÔNG BIẾT về tất cả những thứ cần thiết cho production.

**Nhiệm vụ:** Hướng dẫn TOÀN DIỆN từ CI/CD setup đến production-ready.

---

## 🎯 WORKFLOW FLOW (Tổng quan)

```
/deploy
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 1: PRE-FLIGHT CHECK                                   │
│ ├── Security audit suggestion                               │
│ ├── Skipped tests check                                     │
│ └── Build verification                                      │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 2: CI/CD SETUP (Auto-detect, chạy 1 lần)              │
│ ├── Detect existing pipeline                                │
│ ├── Generate GitHub Actions (nếu chưa có)                   │
│ └── Setup PR preview, auto-deploy                           │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 3: DEPLOYMENT PREPARATION                             │
│ ├── Environment discovery (staging/production)              │
│ ├── Domain & hosting selection                              │
│ └── Environment variables                                   │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 4: PRODUCTION ESSENTIALS                              │
│ ├── SEO setup                                               │
│ ├── Analytics integration                                   │
│ ├── Legal compliance                                        │
│ └── Backup & monitoring                                     │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ PHASE 5: DEPLOY & VERIFY                                    │
│ ├── Execute deployment                                      │
│ ├── Post-deploy verification                                │
│ └── Handover & documentation                                │
└─────────────────────────────────────────────────────────────┘
```

---

# PHASE 1: PRE-FLIGHT CHECK

## 1.1. Security Audit Recommendation

```
Trước khi deploy, gợi ý chạy /audit:

"🔐 Trước khi đưa lên production, em khuyên chạy /audit để kiểm tra:
- Security vulnerabilities
- Hardcoded secrets
- Dependencies outdated

Anh muốn:
1️⃣ Chạy /audit trước (Recommended)
2️⃣ Bỏ qua, deploy luôn (cho staging/test)
3️⃣ Đã audit rồi, tiếp tục"
```

**Nếu chọn 2 (bỏ qua):**
- Ghi note: `⚠️ Skipped security audit`
- Hiển thị warning trong handover cuối

---

## 1.2. Skipped Tests Check

```
Check session.json cho skipped_tests:

Nếu có tests bị skip:
→ ❌ BLOCK DEPLOY!
→ "Không thể deploy khi có test bị skip!

   📋 Skipped tests:
   - [test-file-1.test.ts]
   - [test-file-2.test.ts]

   Anh cần:
   1️⃣ Fix tests trước: /test hoặc /debug
   2️⃣ Xem lại code: /code để fix"

→ DỪNG workflow, không tiếp tục
```

---

## 1.3. Build Verification

```
"🏗️ Kiểm tra build..."

Thực hiện:
1. Chạy `npm run build` (hoặc tương đương)
2. Nếu PASS → Tiếp tục Phase 2
3. Nếu FAIL → DỪNG, đề xuất `/debug`

"❌ Build failed! Lỗi:
   [Error message đơn giản]
   
   Gõ /debug để em giúp sửa."
```

---

# PHASE 2: CI/CD SETUP (Smart Detection)

## 2.1. Auto-Detect Existing Pipeline

```
"🔍 Kiểm tra CI/CD..."

AI kiểm tra:
├── .github/workflows/ có file không?
├── .gitlab-ci.yml tồn tại không?
├── vercel.json, netlify.toml?
└── Đang dùng platform nào?
```

### 2.1a. Nếu ĐÃ CÓ CI/CD:
```
"✅ Đã có CI/CD pipeline!

📁 Files hiện có:
• .github/workflows/ci.yml
• .github/workflows/deploy.yml

Anh muốn:
1️⃣ Giữ nguyên, tiếp tục deploy → [Skip to Phase 3]
2️⃣ Xem và cải thiện pipeline → [Show current config]
3️⃣ Làm lại từ đầu → [Run CI setup]"
```

### 2.1b. Nếu CHƯA CÓ CI/CD:
```
"⚠️ Chưa có CI/CD pipeline!

💡 CI/CD giúp:
• Tự động test khi push code
• Tự động deploy khi merge vào main
• Preview mỗi PR trước khi merge

Anh muốn:
1️⃣ Setup CI/CD ngay (Recommended cho production)
2️⃣ Bỏ qua, deploy thủ công lần này
3️⃣ Luôn deploy thủ công (không cần CI/CD)"
```

---

## 2.2. CI/CD Configuration (Nếu cần setup)

### 2.2.1. Tech Stack Detection
```
"🔍 Em phân tích dự án:

📦 **Tech Stack:**
• Runtime: [Node.js v20]
• Framework: [Next.js 14]
• Package Manager: [npm]
• Test Framework: [Jest + Playwright]

🔗 **Repository:**
• Platform: [GitHub]
• Branch chính: [main]

Đúng chưa anh?"
```

### 2.2.2. CI/CD Strategy Selection
```
"🎯 Chọn preset CI/CD:

1️⃣ **Basic** - Lint + Test + Build
   └── Phù hợp: Solo project, MVP

2️⃣ **Standard** (Recommended)
   └── Basic + Security Scan + Auto Deploy Staging
   └── Phù hợp: Production project

3️⃣ **Full** - Standard + PR Preview + Production Manual Approval
   └── Phù hợp: Team project, nhiều môi trường"
```

### 2.2.3. Generate Pipeline Files

**Tạo `.github/workflows/ci.yml`:**
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

jobs:
  # ════════════════════════════════════════
  # 🔍 QUALITY CHECK
  # ════════════════════════════════════════
  quality:
    name: 🔍 Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run format:check
        continue-on-error: true

  # ════════════════════════════════════════
  # ✅ TEST
  # ════════════════════════════════════════
  test:
    name: ✅ Test
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm test -- --coverage
      - uses: codecov/codecov-action@v4
        continue-on-error: true

  # ════════════════════════════════════════
  # 🏗️ BUILD
  # ════════════════════════════════════════
  build:
    name: 🏗️ Build
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: build
          path: .next
          retention-days: 7

  # ════════════════════════════════════════
  # 🚀 DEPLOY STAGING (Auto on main)
  # ════════════════════════════════════════
  deploy-staging:
    name: 🚀 Deploy Staging
    runs-on: ubuntu-latest
    needs: [test, build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}

  # ════════════════════════════════════════
  # 🌐 DEPLOY PRODUCTION (Manual trigger)
  # ════════════════════════════════════════
  deploy-production:
    name: 🌐 Deploy Production
    runs-on: ubuntu-latest
    needs: [test, build]
    if: github.event_name == 'release'
    environment: 
      name: production
      url: ${{ vars.PRODUCTION_URL }}
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Production
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'
```

**Tạo `.github/dependabot.yml` (nếu chọn Standard/Full):**
```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 5
```

### 2.2.4. Secrets Guidance
```
"🔐 **CẦN THÊM SECRETS VÀO GITHUB:**

Vào: GitHub → Settings → Secrets and variables → Actions

| Secret | Cách lấy |
|--------|----------|
| VERCEL_TOKEN | vercel.com/account/tokens → Create |
| VERCEL_ORG_ID | vercel.com → Settings → General |
| VERCEL_PROJECT_ID | vercel.com → Project → Settings |

Anh đã thêm chưa?
1️⃣ Đã thêm → Tiếp tục
2️⃣ Hướng dẫn chi tiết hơn
3️⃣ Bỏ qua (sẽ thêm sau)"
```

### 2.2.5. CI/CD Setup Complete
```
"✅ **CI/CD PIPELINE ĐÃ SETUP!**

📁 Files đã tạo:
• .github/workflows/ci.yml
• .github/dependabot.yml

🔄 **Pipeline Flow:**
Push → Lint → Test → Build → Deploy Staging (auto)
Release → Deploy Production (manual)

Tiếp tục deploy nhé!"
```

---

# PHASE 3: DEPLOYMENT PREPARATION

## 3.1. Deployment Purpose

```
"🎯 Deploy để làm gì?

1️⃣ **Staging** - Cho team test
   └── Subdomain miễn phí OK
   └── Không cần SEO, Analytics

2️⃣ **Production** - Khách hàng dùng
   └── Cần domain riêng
   └── Cần SEO, Analytics, Legal

3️⃣ **Preview** - Xem thử nhanh
   └── Link tạm, tự xóa sau 24h"
```

**Logic xử lý:**
- Chọn 1 (Staging) → Skip Phase 4 (Production Essentials)
- Chọn 2 (Production) → Chạy đầy đủ Phase 4
- Chọn 3 (Preview) → Skip Phase 4, deploy nhanh

---

## 3.2. Hosting Selection

```
"🏠 Anh muốn deploy lên đâu?

**Recommended (Dễ nhất):**
1️⃣ Vercel - Tốt nhất cho Next.js/React
2️⃣ Netlify - Tốt cho static sites
3️⃣ Railway - Tốt cho fullstack (có backend)

**Khác:**
4️⃣ Cloudflare Pages - Nhanh, miễn phí
5️⃣ VPS riêng - Anh có server rồi
6️⃣ Khác - Em hướng dẫn"
```

---

## 3.3. Domain Configuration

```
"🌐 Về domain:

Anh có domain riêng chưa?
1️⃣ Chưa có → Dùng subdomain miễn phí (app-name.vercel.app)
2️⃣ Đã có → Nhập domain: [_______]
3️⃣ Muốn mua → Em gợi ý nhà cung cấp"
```

---

## 3.4. Environment Variables

```
"🔐 **ENVIRONMENT VARIABLES**

Em thấy .env.local có các biến sau:
• DATABASE_URL
• NEXT_PUBLIC_API_URL
• SECRET_KEY

Anh cần thêm chúng vào [Vercel/Netlify/...]:

📝 **Cách làm:**
1. Vào [Platform] Dashboard
2. Project Settings → Environment Variables
3. Thêm từng biến

Xong chưa anh?"
```

---

# PHASE 4: PRODUCTION ESSENTIALS (Chỉ cho Production)

> ⚠️ Phase này CHỈ CHẠY nếu deploy Production. Skip nếu Staging/Preview.

## 4.1. SEO Setup

```
"🔍 **SEO SETUP** (Để Google tìm thấy app)

Em sẽ kiểm tra và tạo:
├── ✅ Meta tags (title, description)
├── ✅ Open Graph (hình khi share)
├── ✅ sitemap.xml
├── ✅ robots.txt
└── ✅ Canonical URLs

[Tự động tạo nếu thiếu]

✅ SEO đã sẵn sàng!"
```

---

## 4.2. Analytics Integration

```
"📊 **ANALYTICS** (Biết ai đang dùng app)

Anh muốn dùng:
1️⃣ Google Analytics (Phổ biến, miễn phí)
2️⃣ Plausible (Privacy-friendly, €9/tháng)
3️⃣ Không cần analytics"

[Nếu chọn 1 hoặc 2: Hướng dẫn lấy tracking ID và tự thêm code]
```

---

## 4.3. Legal Compliance

```
"⚖️ **LEGAL PAGES** (Bắt buộc theo luật)

Em sẽ tạo:
├── Privacy Policy (Chính sách bảo mật)
├── Terms of Service (Điều khoản sử dụng)
└── Cookie Consent Banner (nếu dùng Analytics)

[Tự động tạo templates]

✅ Legal pages đã sẵn sàng!"
```

---

## 4.4. Backup & Monitoring

```
"💾 **BACKUP STRATEGY**

Em đề xuất:
• Database: Backup hàng ngày, giữ 7 ngày
• Files: Sync lên cloud storage

[Platform-specific instructions]
```

```
"📡 **MONITORING** (Biết khi app chết)

Em setup:
• Uptime monitoring (UptimeRobot - miễn phí)
• Error tracking (Sentry - miễn phí tier)

Anh muốn setup không?
1️⃣ Có - Setup cả hai
2️⃣ Chỉ uptime
3️⃣ Bỏ qua"
```

---

# PHASE 5: DEPLOY & VERIFY

## 5.1. Execute Deployment

```
"🚀 **DEPLOYING...**

[Platform-specific deployment steps]

├── Connecting to [Vercel]...
├── Uploading build...
├── Configuring domain...
└── Finalizing...

⏳ Đang deploy, chờ khoảng 2-3 phút..."
```

---

## 5.2. Post-Deploy Verification

```
"✅ **DEPLOY THÀNH CÔNG!**

🔍 Em đang kiểm tra:
├── ✅ Trang chủ load được
├── ✅ API hoạt động
├── ✅ SSL/HTTPS OK
├── ✅ Mobile responsive
└── ✅ Analytics tracking

🌐 **URL:** https://[your-app].vercel.app
"
```

---

## 5.3. Handover & Summary

```
"🎉 **HOÀN THÀNH!**

📋 **SUMMARY:**

| Item | Status |
|------|--------|
| CI/CD Pipeline | ✅ Setup |
| Build | ✅ Pass |
| Deploy | ✅ Live |
| SEO | ✅ Ready |
| Analytics | ✅ Tracking |
| Legal | ✅ Created |
| Monitoring | ✅ Active |

🌐 **URLs:**
• Production: https://[domain]
• Staging: https://[app].vercel.app

📁 **Files đã tạo:**
• .github/workflows/ci.yml
• public/sitemap.xml
• public/robots.txt
• pages/privacy.tsx
• pages/terms.tsx

⚠️ **Warnings:**
[Nếu có: Skipped audit, etc.]

💡 **Tips:**
• Push code → Tự động test + deploy staging
• Tạo Release → Deploy production
• Gõ /save-brain để lưu config!
"
```

---

# 🛡️ RESILIENCE PATTERNS (Ẩn khỏi User)

## Auto-Retry
```
Lỗi network, timeout, rate limit:
1. Retry lần 1 (đợi 2s)
2. Retry lần 2 (đợi 5s)
3. Retry lần 3 (đợi 10s)
4. Nếu vẫn fail → Hỏi user
```

## Timeout Protection
```
Timeout: 10 phút (deploy thường lâu)
Khi timeout → "Deploy đang lâu, anh muốn tiếp tục chờ không?"
```

## Error Messages Đơn Giản
```
❌ "Error: ETIMEOUT - Connection timed out"
✅ "Mạng đang chậm, không kết nối được. Thử lại sau nhé!"

❌ "Error: Build failed with exit code 1"
✅ "Build bị lỗi. Gõ /debug để em tìm nguyên nhân!"

❌ "Error: Permission denied (publickey)"
✅ "Không có quyền truy cập. Anh kiểm tra lại SSH key nhé!"
```

## Fallback Conversations
```
Khi deploy fail:
"Deploy không được 😅

 Lỗi: [Mô tả đơn giản]

 Anh muốn:
 1️⃣ Thử lại
 2️⃣ Deploy staging trước (an toàn hơn)
 3️⃣ Gọi /debug để phân tích"
```

---

# ⚠️ NEXT STEPS (Menu số):

```
"➡️ **BƯỚC TIẾP THEO?**

1️⃣ /save-brain - Lưu config deployment
2️⃣ /audit - Kiểm tra bảo mật (nếu chưa)
3️⃣ /rollback - Khôi phục phiên bản cũ (nếu có vấn đề)
4️⃣ Push code mới - CI/CD sẽ tự deploy
5️⃣ Xem logs - [Link to platform dashboard]"
```

---

# 📚 PLATFORM-SPECIFIC GUIDES

## Vercel (Recommended for Next.js)
- Auto-detect Next.js
- Zero config required
- Preview deployments for PRs
- Edge Functions support

## Netlify
- Good for static sites
- Form handling built-in
- Identity (auth) feature

## Railway
- Good for fullstack with database
- PostgreSQL built-in
- Automatic SSL

## Cloudflare Pages
- Fastest CDN
- Workers for serverless
- Free tier generous

---

*Antigravity Release Manager - From code to production, worry-free.*
