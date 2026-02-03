# GitSummarizer – App Store Publishing Checklist

Use this checklist before submitting GitSummarizer to the Mac App Store.

---

## 1. Code & configuration (done in this pass)

- [x] **Bundle IDs** – Main app: `TiTiBooL.GitSummarizer`, Extension: `TiTiBooL.GitSummarizer.Extension`. Popup and ViewController reference these correctly.
- [x] **Copyright** – `NSHumanReadableCopyright` set to "Copyright © 2026. All rights reserved." (update year/name in Xcode if needed).
- [x] **Debug logging** – `console.log` removed from extension background script.

---

## 2. App icons

- [ ] **Main app icon (Dock / Finder)**  
  In Xcode: **GitSummarizer** target → **Assets.xcassets** → **AppIcon**.  
  Add PNGs for all required sizes (16, 32, 128, 256, 512 @1x and @2x), or a single 1024×1024 if your Xcode supports it.  
  You can export from `Github Summeriser/Resources/Icon.svg` or your design tool.

- [ ] **Extension icons**  
  Under **Github Summeriser Extension/Resources/images/** you have:  
  `icon-48.png`, `icon-96.png`, `icon-128.png`, `icon-256.png`, `icon-512.png`, and `toolbar-icon.svg`.  
  Ensure all PNGs match your branding (same design as the app icon).

---

## 3. App Store Connect

- [ ] **Create app** – App Store Connect → **My Apps** → **+** → **New App** (macOS).
- [ ] **Bundle ID** – Select or register `TiTiBooL.GitSummarizer` (must match Xcode).
- [ ] **Privacy Policy URL** – Required. Host a page that explains:
  - GitSummarizer only runs in Safari and only on GitHub pages you visit.
  - Summaries and chat use Apple’s on-device Foundation Model (Apple Intelligence); no project content is sent to external servers.
  - No analytics or tracking.
- [ ] **App Privacy** – In App Store Connect, complete **App Privacy**:
  - Data **not** collected (no account, no usage data sent off-device).
  - If you add analytics later, declare them here.

---

## 4. App information (App Store Connect)

- [ ] **Name** – GitSummarizer.
- [ ] **Subtitle** – Short line (e.g. “Summarise & chat about GitHub repos”).
- [ ] **Description** – Explain: one-click summary of GitHub projects and in-popup chat using Apple Intelligence (on-device).
- [ ] **Keywords** – e.g. github, summarise, safari extension, apple intelligence.
- [ ] **Category** – e.g. Developer Tools.
- [ ] **Screenshots** – At least one macOS screenshot (Safari with a GitHub repo + GitSummarizer popup open). Required sizes: see [App Store screenshot specs](https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications).
- [ ] **Copyright** – Same as in the app (e.g. “Copyright © 6. All rights reserved.”).

---

## 5. Safari extension (Apple’s requirements)

- [ ] **Extension description** – In **Github Summeriser Extension/Resources/_locales/en/messages.json**, `extension_description` is used in Safari’s extension list. Already set; adjust wording if needed.
- [ ] **Permissions** – Manifest uses only `activeTab` and `nativeMessaging`. No extra permissions.
- [ ] **Host app** – The containing app (GitSummarizer) must be the one shipped to the App Store; the extension is embedded in it.

---

## 6. Technical

- [ ] **Signing** – In Xcode, use your **Distribution** certificate and **App Store** provisioning profile for the GitSummarizer target (and the extension).
- [ ] **Archive** – Product → **Archive**. Validate, then **Distribute App** → **App Store Connect**.
- [ ] **macOS version** – Extension: macOS 10.14+; Foundation Model features need macOS 26+ and Apple Intelligence. Test on a supported Mac.
- [ ] **Export compliance** – If asked: no encryption beyond standard HTTPS / Apple APIs; answer accordingly in App Store Connect.

---

## 7. Before you submit

- [ ] **Test** – Install the archived build, enable the extension in Safari, open a GitHub repo, run summarise and chat. Confirm no crashes and correct behaviour.
- [ ] **Privacy policy** – URL added in App Store Connect and linked from your policy page.
- [ ] **Copyright year** – Update “2026” in the app and in App Store Connect if needed.

---

## Quick reference

| Item              | Where / value                          |
|-------------------|----------------------------------------|
| Main app bundle ID| `TiTiBooL.GitSummarizer`                      |
| Extension bundle ID | `TiTiBooL.GitSummarizer.Extension`          |
| Native messaging (popup) | Host app: `TiTiBooL.GitSummarizer`   |
| Copyright         | Copyright © 2026. All rights reserved. |

After completing the unchecked items above, you’re ready to submit GitSummarizer for App Store review.
