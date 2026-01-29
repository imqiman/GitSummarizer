# GitSummarizer – Console Warnings Explained

When you run GitSummarizer, you may see several console messages. Here’s what they mean and what (if anything) to do.

---

## 1. Internal inconsistency in menus

**What it says:** The “GitSummarizer” and “Help” menus believe their parent is “Main Menu”, but Main Menu doesn’t appear to list them as items.

**Cause:** AppKit sometimes builds the menu bar before the storyboard’s menu items are fully attached, so a consistency check fails even though the menus work.

**What we did:** The storyboard was updated so the main menu is built entirely from the storyboard (no `systemMenu="main"`), which usually removes this warning.

**If it still appears:** The menus still work; this is a known AppKit quirk. You can ignore it or try: Product → Clean Build Folder, then run again.

---

## 2. AFPreferences / AFIsDeviceGreymatterEligible / Apple Intelligence

**Examples:**
- `No language code saved, but Assistant is enabled`
- `AFIsDeviceGreymatterEligible Missing entitlements for os_eligibility lookup`

**Cause:** The system (and possibly the Foundation Models framework) is checking Apple Intelligence / “Greymatter” eligibility. These logs come from system frameworks, not from your app code.

**What to do:** Nothing. You can’t fix or silence these. They don’t affect GitSummarizer’s behaviour.

---

## 3. WebContent sandbox / pboard / LaunchServices / XPC

**Examples:**
- `Connection to 'pboard' server had an error` … `Sandbox restriction`
- `Failed to set up CFPasteboardRef`
- `launchservicesd` … `Sandbox restriction`
- `com.apple.lsd.modifydb` … `Operation not permitted`

**Cause:** The main app window uses a **WKWebView** to show `Main.html`. That WebView runs in a **sandboxed WebContent process**. The sandbox correctly blocks that process from:
- Pasteboard (clipboard)
- LaunchServices
- Some other system services

So the WebContent process logs “connection invalid” or “permission denied” when it touches those APIs.

**Impact:** Your in-app window only shows extension status and a button; it doesn’t need clipboard or LaunchServices. The **Safari extension popup** (where Copy works) runs inside Safari, not in this WebView, so Copy in the extension is unaffected.

**What to do:** Nothing. These messages are expected for a sandboxed app and can be ignored.

---

## 4. Other WebContent / system messages

- **`invalid product id '(null)'`** – LaunchServices in the WebContent process; harmless.
- **`binary.metallib invalid format`** – Shader/metallib loading; often simulator or OS-specific and not actionable.
- **`Unable to hide query parameters from script (missing data)`** – Minor WebKit message; safe to ignore.
- **`networkd_settings_read_from_file Sandbox is preventing...`** – Sandbox blocking WebContent from reading system network config; expected.

---

## Summary

| Warning type              | Action        | Affects app? |
|---------------------------|---------------|--------------|
| Menu inconsistency        | Fixed in storyboard; ignore if it still appears | No |
| AFPreferences / Greymatter | None          | No |
| WebContent / pboard / XPC / sandbox | None | No |
| Other WebContent / system | None          | No |

None of these indicate a bug in your code. GitSummarizer and the Safari extension should behave normally; you can treat these as console noise.
