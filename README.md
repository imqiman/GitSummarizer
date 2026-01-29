# Gitsum

A Safari extension that summarises GitHub projects and lets you chat about them using **Apple’s on-device Foundation Model** (Apple Intelligence).

- **One click** – Open any GitHub repo, click the Gitsum icon, then “Summarise with Apple Intelligence”.
- **Chat** – Ask questions about the project in the popup; answers use the repo’s README and description.
- **Private** – Summarisation and chat run on your Mac with Apple Intelligence; no data is sent to external servers.

## Requirements

- **macOS 26+** with **Apple Intelligence** enabled (for summarisation and chat).
- **Safari** (the extension runs in Safari).

## Installation

1. Clone or download this repo.
2. Open `Gitsum.xcodeproj` in Xcode.
3. Select the **Gitsum** scheme and run (⌘R).
4. In Safari: **Settings → Extensions** → enable **Gitsum**.

## Usage

1. Open a GitHub repository page (e.g. `github.com/owner/repo`).
2. Click the Gitsum icon in the Safari toolbar.
3. Click **Summarise with Apple Intelligence**.
4. Read the summary and use the chat to ask questions about the project.

## Project structure

- **Gitsum** (main app) – Host app that ships the extension and shows extension status.
- **Gitsum Extension** – Safari Web Extension: content script (GitHub), popup (summary + chat), native handler (Apple Foundation Models).

## License

Copyright © 2025. All rights reserved.
