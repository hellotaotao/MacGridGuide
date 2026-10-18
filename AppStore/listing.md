# Grid Guide 1.4.0: App Store Connect listing

Bundle ID `com.hellotaotao.GridGuide` · Mac App Store · macOS 13.0+ · sandboxed menu bar app (`LSUIElement`) · collects no data.

Character counts in brackets were checked against the App Store Connect limits.

## App information

| Field | Value |
| --- | --- |
| Name | **Grid Guide** [10/30] |
| Primary category | Utilities |
| Secondary category | Developer Tools (alternative: Graphics & Design) |
| Age rating | 4+ (answer "None" / "No" to every questionnaire item) |
| Content rights | Does not contain, show or access third-party content |
| Copyright | 2024–2026 Tao Wang |
| Support URL | https://github.com/hellotaotao/MacGridGuide/issues |
| Marketing URL | https://github.com/hellotaotao/MacGridGuide (optional) |
| Privacy Policy URL | https://hellotaotao.github.io/MacGridGuide/AppStore/privacy-policy.html (live after GitHub Pages is enabled, see `privacy-policy.html`) |
| Export compliance | Already answered in the binary: `ITSAppUsesNonExemptEncryption = NO` |

### Name availability

Checked on 2026-10-19 with the iTunes Search API (Mac and iOS stores, US) and web search: no app is named exactly "Grid Guide". The nearest names are "Drawing Grid Guide" (iOS drawing aid), "PixelGriddle" and "Red Lines Tools" (Mac overlays), none of which block the name. The only definitive check is App Store Connect itself, so create the app record early to reserve the name. App names are unique across all stores and also collide with names that are reserved but not yet live.

Fallbacks if it is taken, in order:

1. `Grid Guide: Layout Overlay` [26]
2. `Grid Guide – Screen Grid` [24]
3. `GridGuide` [9]

Keep "Grid Guide" first in any fallback: it matches the bundle display name and the menu titles.

## Version information (English, U.S.)

### Subtitle [25/30]

```
Layout grids over any app
```

Alternatives: `Column & baseline grid overlay` [30], `On-screen columns and 8pt grid` [30].

### Promotional text [159/170]

```
Put your design's column grid over the real thing. 12-column, 8pt and baseline grids on every display, click-through, one shortcut away. No permissions needed.
```

### Keywords [98/100]

```
overlay,layout,columns,baseline,8pt,alignment,spacing,css,frontend,developer,designer,pixel,thirds
```

"grid" and "guide" are left out because the name is already indexed. Third-party product names such as Figma are left out of the name, subtitle and keywords on purpose: guideline 2.3.7 treats them as keyword stuffing and they are a common rejection reason.

### Description

```
Grid Guide puts a layout grid over your whole screen, the same kind of columns and baseline you set up on a frame in your design tool, except it sits on top of every app. Open the page you are building, press a shortcut, and see at a glance whether the content really lines up with the design.

Built for front-end developers checking an implementation against a column design, and for designers checking spacing in a live product, a prototype or a screenshot.

LAYOUTS YOU CAN STACK
• Columns: 1 to 24 columns with gutter, side margin and a centred max width, like a CSS container. Set max width to 0 to span the whole display.
• Square grid: any cell size from 4 to 400 pt, drawn as full squares, rows only (a baseline grid) or vertical lines only.
• Guides: centre lines and rule of thirds.
• Combine all three in one layout, for example 12 columns plus a 24 pt baseline.
• Ready-made layouts: 12 Columns (1200 pt, 24 pt gutters), 8pt Grid, Square Grid and Rule of Thirds. Add, duplicate, rename, reorder and delete your own.

Values are in points, which match CSS pixels in a browser at 100% zoom, so the numbers from your stylesheet work as they are.

STAYS OUT OF THE WAY
• Click-through: the grid never blocks the mouse or keyboard.
• Covers every connected display and follows display changes, Spaces and full-screen apps.
• Lines snap to the pixel grid so they stay crisp on Retina displays.
• Show or hide from anywhere with Control-Option-Command-G, and cycle layouts with Control-Option-Command-N. Both shortcuts can be re-recorded.
• Lives in the menu bar: switch layouts and adjust opacity without opening a window.

MAKE IT VISIBLE ON ANY CONTENT
• Any line colour, plus quick swatches.
• Line width from 0.5 to 4 pt and opacity from 10% to 100%.
• Contrast outline adds a light or dark edge to every line, so the grid reads on both light and dark pages.

PRIVATE BY DESIGN
Grid Guide needs no Accessibility or Screen Recording permission: it only draws, it never reads what is on your screen. It runs in the App Sandbox, makes no network connections and collects no data.

Optional launch at login. Requires macOS 13 Ventura or later.
```

[~2,150/4,000 characters]

### What's New in This Version

First Mac App Store release, so App Store Connect does not ask for this field. For later versions, start from this summary of 1.4.0:

```
• Layouts: combine columns, a square or baseline grid, and centre or thirds guides
• Column grids with gutter, margin and max width
• Line colour, width, opacity and a contrast outline
• New settings window with recordable global shortcuts
• Launch at login
```

## App Review information

Sign-in required: **No**. Contact: Tao Wang (fill in phone and email in App Store Connect).

### Notes

```
Grid Guide is a menu bar utility (LSUIElement), so it has no Dock icon and no main window.

How to review:
1. Launch the app. A grid overlay appears immediately on every display, and because this is the first launch the Settings window opens with a short welcome message.
2. The grid icon in the menu bar opens a menu to show or hide the grid, pick a layout (Square Grid, 8pt Grid, 12 Columns, Rule of Thirds), go to the next layout, change opacity, open Settings, or quit.
3. Global shortcuts, which work from any app:
   - Control-Option-Command-G (⌃⌥⌘G): show or hide the grid
   - Control-Option-Command-N (⌃⌥⌘N): switch to the next layout
   Both can be changed in Settings > General.
4. If the Settings window is closed, open it again from the menu bar item (Settings…), or open the app again from Finder or Launchpad, which brings the Settings window forward.

The overlay ignores all mouse events, so you can keep using other apps underneath it.

Permissions and data: the app requests no permissions. Global shortcuts are registered with the Carbon RegisterEventHotKey API, which needs no Accessibility access, and the app never captures the screen. "Launch at login" in Settings > General uses SMAppService.mainApp. The app makes no network requests and collects no data. Settings are stored locally in UserDefaults.
```

## App Privacy (App Store Connect › App Privacy)

| Question | Answer |
| --- | --- |
| Do you or your third-party partners collect data from this app? | **No, we do not collect data from this app** |
| Resulting label | **Data Not Collected** |
| Tracking | None. No IDFA, no SDKs, no network access |
| Privacy manifest | `GridGuide/PrivacyInfo.xcprivacy`: no tracking, no collected data types, one required-reason API (UserDefaults, `CA92.1`) |

## Screenshots

`screenshots/` holds four 2880 × 1800 PNGs (16:10, accepted size for Mac). Upload them in this order:

| File | Shows |
| --- | --- |
| `01-columns.png` | Built-in **12 Columns** layout (1200 pt max width, 24 pt gutters) over a landing page served from `localhost`; the page content lines up with the columns |
| `02-8pt-grid.png` | **8pt Grid** in blue at 35% opacity over a web app settings screen built on 8 pt spacing |
| `03-baseline.png` | Custom layout: 6 columns (960 pt, 32 pt gutters) plus a 24 pt rows-only baseline grid in magenta over a dark-mode article |
| `04-settings.png` | Settings window on first launch: welcome banner with the ⌃⌥⌘G shortcut and the Layouts tab editing 12 Columns |

How they were made: the grid and the settings window are rendered by the app's own `GridGuideView` and `SettingsView` code, not redrawn. `screenshots/tools/` compiles those views into an offscreen harness, renders the background pages (fictional products, no real brands) with headless Chrome at 1440 × 900 pt @2x, and composites them. Run `AppStore/screenshots/tools/make.sh` to regenerate after UI changes. Two limits of this approach:

- The menu bar and browser toolbar in the backgrounds are drawn in HTML, not captured from macOS.
- The accent colour (selected row, toggles, Got It button) is whatever this Mac renders as its system accent, currently indigo. On a Mac with the default blue accent those controls will be blue.

Only the composited PNGs are uploaded; there is no marketing caption text on them. If you would rather submit real captures, set the display to a 16:10 mode (for example 1440 × 900 HiDPI), use the same four scenes, and take them with ⌘⇧3.

## Simplified Chinese (zh-Hans), optional

The app UI is English only. Localized metadata is still allowed and helps Chinese App Store search.

| Field | Value |
| --- | --- |
| 名称 | Grid Guide |
| 副标题 [12/30] | 在任意应用上叠加布局栅格 |
| 推广文本 [64/170] | 把设计稿里的栅格直接叠在真实页面上。12 栏、8pt、基线网格覆盖所有显示器，鼠标可穿透，一个快捷键随时开关。无需任何系统权限。 |
| 关键词 [55/100] | 栅格,网格,参考线,布局,对齐,基线,间距,前端,开发,设计,像素,叠加,三分法,overlay,layout |

描述：

```
Grid Guide 把布局栅格铺满整个屏幕：就是你在设计工具里给画板设置的那种栏和基线，只不过它浮在所有应用之上。打开正在开发的页面，按一下快捷键，就能看出内容和设计稿到底对没对齐。

适合对照栅格设计稿检查实现的前端开发者，也适合在真实产品、原型或截图上检查间距的设计师。

可叠加的布局
• 栏：1 到 24 栏，可设栏间距、边距和居中最大宽度，和 CSS 容器一样。最大宽度设为 0 即铺满整个显示器。
• 方格：4 到 400 pt 任意格子大小，可画完整方格、只画横线（基线网格）或只画竖线。
• 参考线：中线和三分线。
• 三者可以组合在一个布局里，比如 12 栏加 24 pt 基线。
• 内置布局：12 Columns（1200 pt，24 pt 栏间距）、8pt Grid、Square Grid 和 Rule of Thirds，也可以新建、复制、重命名、排序和删除自己的布局。

数值单位是 pt，在浏览器 100% 缩放下等于 CSS 像素，样式表里的数字可以直接拿来用。

不碍事
• 鼠标穿透：栅格从不挡住鼠标和键盘。
• 覆盖所有显示器，跟随显示器变化、多个桌面空间和全屏应用。
• 线条对齐像素网格，在 Retina 屏上保持清晰。
• 任何地方按 Control-Option-Command-G 显示或隐藏，Control-Option-Command-N 切换布局，两个快捷键都可以重新录制。
• 常驻菜单栏：不开窗口也能切换布局、调整不透明度。

在任何内容上都看得清
• 任意线条颜色，附快捷色板。
• 线宽 0.5 到 4 pt，不透明度 10% 到 100%。
• 对比描边给每条线加一圈深色或浅色边，在浅色和深色页面上都清楚。

隐私
Grid Guide 不需要辅助功能或屏幕录制权限：它只负责画线，从不读取屏幕内容。运行在 App 沙盒中，不联网，不收集任何数据。

可选开机自启动。需要 macOS 13 Ventura 或更高版本。
```

## Still to do in App Store Connect

1. Create the app record (this reserves the name), choose Mac platform and the bundle ID above.
2. Enable GitHub Pages for the repo (Settings › Pages › Deploy from branch `main`, folder `/ (root)`), then confirm the privacy policy URL loads.
3. Set the price and availability.
4. Upload the 1.4.0 build from Xcode (Product › Archive › Distribute App › App Store Connect), then attach it to the version.
5. Paste the fields above, upload the screenshots, answer App Privacy and the age rating, and submit.
