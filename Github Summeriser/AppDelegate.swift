//
//  AppDelegate.swift
//  GitSummarizer
//
//  Created by Shahriyar Nikbin on 1/29/26.
//

import Cocoa
import SafariServices

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    private var statusItem: NSStatusItem?
    private var statusMenu: NSMenu?

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMainMenu()
        setupMenuBarExtra()
    }

    // MARK: - Main menu (fixes storyboard menu inconsistency so "GitSummarizer" menu works)

    private func buildMainMenu() {
        let mainMenu = NSMenu()

        // App menu (GitSummarizer)
        let appMenuItem = NSMenuItem(title: "GitSummarizer", action: nil, keyEquivalent: "")
        let appMenu = NSMenu(title: "GitSummarizer")
        appMenu.addItem(withTitle: "About GitSummarizer", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Hide GitSummarizer", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthersItem = NSMenuItem(title: "Hide Others", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthersItem.keyEquivalentModifierMask = [.option, .command]
        appMenu.addItem(hideOthersItem)
        appMenu.addItem(withTitle: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit GitSummarizer", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenu.items.forEach { $0.target = NSApp }
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)

        // Help menu
        let helpMenuItem = NSMenuItem(title: "Help", action: nil, keyEquivalent: "")
        let helpMenu = NSMenu(title: "Help")
        helpMenu.addItem(withTitle: "GitSummarizer Help", action: #selector(NSApplication.showHelp(_:)), keyEquivalent: "?")
        helpMenu.items.forEach { $0.target = NSApp }
        helpMenuItem.submenu = helpMenu
        mainMenu.addItem(helpMenuItem)

        NSApp.mainMenu = mainMenu
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // MARK: - Menu bar extra

    private func setupMenuBarExtra() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        // Use app icon for menu bar (small size, template for light/dark menu bar)
        if let image = loadMenuBarIcon() {
            image.isTemplate = true
            button.image = image
        }
        button.toolTip = "GitSummarizer"

        statusMenu = NSMenu()
        statusMenu?.addItem(withTitle: "About GitSummarizer", action: #selector(showAbout(_:)), keyEquivalent: "")
        statusMenu?.addItem(NSMenuItem.separator())
        statusMenu?.addItem(withTitle: "Open Safari Extensions…", action: #selector(openSafariExtensions(_:)), keyEquivalent: "")
        statusMenu?.addItem(withTitle: "Show Main Window", action: #selector(showMainWindow(_:)), keyEquivalent: "")
        statusMenu?.addItem(NSMenuItem.separator())
        statusMenu?.addItem(withTitle: "Quit GitSummarizer", action: #selector(quit(_:)), keyEquivalent: "q")

        statusMenu?.items.forEach { $0.target = self }
        statusItem?.menu = statusMenu
    }

    private func loadMenuBarIcon() -> NSImage? {
        // Prefer Icon.png from app bundle (Resources)
        if let url = Bundle.main.url(forResource: "Icon", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            let size = NSSize(width: 18, height: 18)
            let small = NSImage(size: size)
            small.lockFocus()
            NSGraphicsContext.current?.imageInterpolation = .high
            image.draw(in: NSRect(origin: .zero, size: size), from: NSRect(origin: .zero, size: image.size), operation: .copy, fraction: 1)
            small.unlockFocus()
            return small
        }
        // Fallback: app icon from asset catalog
        return NSImage(named: NSImage.applicationIconName)
    }

    @objc private func showAbout(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            NSApplication.AboutPanelOptionKey.credits: "Safari extension to summarise and chat about GitHub repos with Apple Intelligence.",
            NSApplication.AboutPanelOptionKey(rawValue: "Copyright"): "Copyright © 2025. All rights reserved."
        ])
    }

    @objc private func openSafariExtensions(_ sender: Any?) {
        SFSafariApplication.showPreferencesForExtension(withIdentifier: extensionBundleIdentifier) { _ in }
    }

    @objc private func showMainWindow(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows.first { $0.canBecomeMain }?.makeKeyAndOrderFront(nil)
    }

    @objc private func quit(_ sender: Any?) {
        NSApp.terminate(nil)
    }
}
