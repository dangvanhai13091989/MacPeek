# MacPeek — Hướng dẫn Marketing & Quảng cáo

## 📋 Thông tin sản phẩm

| Thông tin | Giá trị |
|-----------|---------|
| **Tên** | MacPeek |
| **Website** | https://macpeek.pages.dev |
| **GitHub** | https://github.com/dangvanhai13091989/MacPeek |
| **Gumroad** | https://vanhaimagic.gumroad.com/l/macpeek |
| **Giá** | Miễn phí, mã nguồn mở; donate tùy chọn |
| **Nền tảng** | macOS 14+ (Sonoma) |
| **Cập nhật** | Tự động qua Sparkle + GitHub Releases |

---

## 1. 🔴 Reddit

### ⚠️ r/macapps yêu cầu karma! Đăng ở đây TRƯỚC:

| Subreddit | Karma cần? | Ghi chú |
|-----------|-----------|---------|
| **r/SideProject** | ❌ Không | ✅ **Đăng ngay được!** Chuyên cho indie dev |
| **r/IndieDev** | ❌ Không | ✅ **Đăng ngay!** Chia sẻ dự án cá nhân |
| **r/InternetIsBeautiful** | ❌ Không | ✅ Chia sẻ website/tool hay |
| **r/coolgithubprojects** | ❌ Không | ✅ Có repo GitHub rồi |
| **r/opensource** | ❌ Không | ✅ Nếu muốn open-source |
| **r/ProductHunt** | ❌ Không | ✅ Cross-promote |
| r/macapps | ⚠️ **Cần karma** | Đăng SAU khi có karma |
| r/mac | ⚠️ Có thể cần | Thử đăng xem |

### 🎯 Cách lấy karma nhanh cho r/macapps:

1. Vào **r/macapps** → tìm bài hỏi "best app for X?"
2. **Comment** giúp đỡ (trả lời câu hỏi, gợi ý app)
3. Mỗi upvote = +1 karma → cần ~10-20 karma
4. Mất khoảng **2-3 ngày** comment → đủ karma → đăng bài

### 📝 Bài đăng cho r/macapps (Copy-paste):

**Title:**
```
MacPeek — Preview any window by hovering over Dock icons (like Windows taskbar preview, but for Mac)
```

**Body:**
```
Hey r/macapps! 👋

I built MacPeek because I've always missed the Windows taskbar hover preview feature on macOS. You know — hover over a taskbar icon and instantly see what's in that window? macOS doesn't have this natively, so I made it.

**What it does:**
- Hover over any Dock icon → instantly see a live preview of its windows
- Multiple windows? Shows a beautiful grid with all of them
- Click any preview thumbnail → switches directly to that window
- Works with multiple monitors
- Close individual windows right from the preview popup

**Tech details:**
- Built with SwiftUI + Accessibility API
- Native Swift app with minimal idle CPU usage
- Runs silently in the menu bar
- Supports 18 languages
- macOS 14+ (Sonoma or later)

**Privacy:** Zero data collection and no analytics. Window previews stay local. Network access is used only for signed update checks.

**Pricing:** Free and open source under GPL-3.0. Donations are optional.

🔗 Website: https://macpeek.pages.dev
🔗 Source: https://github.com/dangvanhai13091989/MacPeek
🔗 Download: https://github.com/dangvanhai13091989/MacPeek/releases/latest/download/MacPeek.dmg

Happy to answer any questions! Would love your feedback.
```

---

### 📝 Bài đăng cho r/SideProject (Copy-paste):

**Title:**
```
I open-sourced a macOS utility that adds Windows-style taskbar preview to the Dock
```

**Body:**
```
Hey everyone! I'm a solo dev and just shipped MacPeek — a tiny macOS utility that lets you preview app windows by hovering over Dock icons.

**The problem:** macOS has no native way to peek at a window without switching to it. If you have 10 Chrome windows open, you have to click through each one to find the right one.

**The solution:** MacPeek adds a hover preview popup (like Windows taskbar) to the macOS Dock. Hover over Chrome → see all 10 windows as thumbnails → click the one you want.

**Features:**
- Real-time window preview on Dock hover
- Multi-window grid for apps with many windows
- Click to switch to a specific window
- Close windows directly from the preview
- Multi-monitor support
- 18 languages
- Native and lightweight
- Signed automatic updates

**Stack:** Swift, SwiftUI, Accessibility API, ScreenCaptureKit

**Business model:** Free and open source. Optional donations support continued development.

Website: https://macpeek.pages.dev
GitHub: https://github.com/dangvanhai13091989/MacPeek

Would love any feedback on the product or the landing page! 🙏
```

---

### 📝 Bài đăng cho r/mac (Copy-paste):

**Title:**
```
I made a free utility that adds hover preview to the macOS Dock (like Windows taskbar preview)
```

**Body:**
```
One feature I always missed from Windows was hovering over a taskbar icon to see a preview of the window. macOS doesn't have this, so I built MacPeek.

Just hover over any app icon in the Dock and you instantly see a live preview of its windows. If an app has multiple windows, they show up in a nice grid. Click any thumbnail to jump straight to that window.

It's a lightweight native app, runs in the menu bar, and supports 18 languages.

Free and open source: https://macpeek.pages.dev

Thought you guys might find this useful!
```

---

## 2. 🟠 Hacker News (news.ycombinator.com)

### 📝 Post dạng "Show HN" (Copy-paste):

**Title:**
```
Show HN: MacPeek – Windows-style taskbar preview for macOS Dock
```

**Body:**
```
Hi HN,

I built MacPeek, a small macOS utility that adds window preview on Dock hover — similar to how Windows shows taskbar thumbnails.

How it works:
- Hover over any Dock icon → live preview popup appears
- Multiple windows → shows a grid of thumbnails
- Click any thumbnail → switches to that specific window
- You can even close individual windows from the preview

Technical details:
- Built with SwiftUI + AXUIElement Accessibility API + ScreenCaptureKit
- Uses CGWindowListCopyWindowInfo for window enumeration
- Parallel capture with Swift TaskGroup for multi-window performance
- Native Swift app with minimal idle CPU usage
- Coordinate conversion handles multi-monitor setups correctly (primary screen vs NSScreen.main was a fun bug to fix)

Privacy: No analytics or data collection. Window previews stay local; network access is only for signed update checks.

Free and open source under GPL-3.0. Optional donations support maintenance.

Website: https://macpeek.pages.dev
Source: https://github.com/dangvanhai13091989/MacPeek
```

---

## 3. 🟣 Product Hunt

### Cách đăng:

1. Vào https://www.producthunt.com/posts/new
2. Điền thông tin:

**Tagline:**
```
Preview any window by hovering over macOS Dock icons
```

**Description:**
```
MacPeek brings the Windows taskbar hover preview feature to macOS. Simply hover over any Dock icon to see a live preview of its windows — no clicking, no switching. Apps with multiple windows show a beautiful grid. Click any thumbnail to jump straight to that window.

Built for productivity nerds who work with many windows.

• Real-time window preview on Dock hover
• Multi-window grid with pagination
• Click to switch or close individual windows
• Multi-monitor support
• 18 languages
• Privacy-first: zero data collection
• Native Swift app with automatic updates

Free and open source under GPL-3.0. Donations are optional.
```

**Topics:** `Productivity`, `Mac`, `Developer Tools`, `Tech`

> [!TIP]
> **Best time to launch on Product Hunt:** Chủ nhật 11PM PST (= Thứ 2 đầu giờ sáng ở Mỹ). Product Hunt reset bảng xếp hạng lúc 12:01 AM PST hàng ngày. Post vào đêm CN để có cả ngày Thứ 2 để thu thập upvotes.

---

## 4. 🐦 Twitter/X

### 📝 Thread giới thiệu (Copy-paste):

**Tweet 1:**
```
I just shipped MacPeek 🚀

A tiny macOS utility that adds hover preview to the Dock — like Windows taskbar preview, but for Mac.

Hover over any Dock icon → see its windows instantly.

Free and open source. Optional donations support future updates.

🔗 https://macpeek.pages.dev

🧵 Here's what it does:
```

**Tweet 2:**
```
Problem: macOS has NO way to peek at a window without switching to it.

If you have 10 Chrome windows open, good luck finding the right one.

MacPeek fixes this — hover over Chrome's Dock icon and see ALL windows as thumbnails. Click the one you want.
```

**Tweet 3:**
```
Features:
✅ Live window preview on Dock hover
✅ Multi-window grid
✅ Click to switch to any window
✅ Close windows from preview
✅ Multi-monitor support
✅ 18 languages
✅ Native and lightweight
✅ Privacy-first (no data collection)
✅ Signed automatic updates
```

**Tweet 4:**
```
Tech stack:
- SwiftUI
- Accessibility API (AXUIElement)
- ScreenCaptureKit
- Sparkle for signed automatic updates
- GitHub Releases for distribution

Built as a solo dev side project. Happy to answer any questions! 🙌
```

### Hashtags:
```
#macOS #macapp #productivity #indiedev #buildinpublic #swiftui #apple #sideproject
```

---

## 5. 🌐 Các nền tảng khác

### AlternativeTo.net
1. Vào https://alternativeto.net/software/macpeek/
2. Thêm MacPeek như alternative cho **"Windows Taskbar Thumbnails"** hoặc **"Peek"**

### macOS App directories:
- https://macmenubar.com — Submit app
- https://setapp.com — Apply (nếu đủ lớn)

### Tiếng Việt — Diễn đàn VN:

**Tinhte.vn:**
```
[Chia sẻ] MacPeek — Xem trước cửa sổ khi di chuột qua Dock trên macOS

Mình vừa làm xong một ứng dụng nhỏ cho macOS tên MacPeek. Chức năng đơn giản: di chuột qua icon app trên Dock → hiện preview cửa sổ đang mở của app đó, giống như hover trên taskbar Windows.

Tính năng chính:
- Xem trước cửa sổ theo thời gian thực
- App có nhiều cửa sổ → hiện dạng lưới
- Click vào preview → chuyển thẳng đến cửa sổ đó
- Đóng cửa sổ ngay từ preview
- Hỗ trợ đa màn hình
- 18 ngôn ngữ (có tiếng Việt)
- Native, nhẹ, không thu thập dữ liệu
- Tự động cập nhật an toàn

Miễn phí và mã nguồn mở theo GPL-3.0. Donate hoàn toàn tùy chọn.

Download: https://macpeek.pages.dev
GitHub: https://github.com/dangvanhai13091989/MacPeek

Mọi người dùng thử feedback giúp mình nhé! 🙏
```

---

## 📅 Lịch đăng bài khuyến nghị

| Ngày | Nền tảng | Ghi chú |
|------|----------|---------|
| Ngày 1 | Reddit r/macapps | Bài chính, quan trọng nhất |
| Ngày 1 | Twitter/X thread | Cùng ngày với Reddit |
| Ngày 2 | Reddit r/SideProject | Góc nhìn indie dev |
| Ngày 3 | Hacker News Show HN | Cần timing tốt (sáng giờ Mỹ) |
| Ngày 4 | Reddit r/mac | Bài nhẹ nhàng hơn |
| Ngày 5 | Product Hunt | Launch riêng |
| Ngày 5 | Tinhte.vn | Cộng đồng VN |
| Tuần 2 | AlternativeTo, macmenubar.com | SEO dài hạn |

---

## ⚠️ Tips tránh bị xóa bài / ban

1. **Reddit**: Mỗi subreddit đăng **1 lần duy nhất**. Không spam. Trả lời mọi comment.
2. **Hacker News**: Không dùng từ "Show HN" nếu không phải bạn tự làm. Phải trả lời comments.
3. **Product Hunt**: Chỉ launch **1 lần**. Nhờ bạn bè upvote nhưng **KHÔNG** dùng bot.
4. **Tất cả**: Luôn disclose đây là **sản phẩm của bạn**. Trung thực = uy tín.
