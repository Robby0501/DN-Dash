//
//  AppDelegate.swift
//  IP.Check
//
//  Created by Robby Ulrich on 8/29/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a status item in the menu bar with a variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set the title of the status item (the text displayed in the menu bar)
        if let button = statusItem?.button {
            button.title = "IP Check"
        }

        // Create a new NSMenu instance to be displayed when the status item is clicked
        let menu = NSMenu()

        // Create a custom menu item that contains the CustomView
        let customViewItem = NSMenuItem()
        customViewItem.view = CustomView(frame: NSRect(x: 0, y: 0, width: 250, height: 200))
        menu.addItem(customViewItem)

        // Add a simple text menu item to ensure the menu functions correctly
        menu.addItem(NSMenuItem(title: "Hello", action: #selector(printHello), keyEquivalent: "H"))

        // Add a separator item
        menu.addItem(NSMenuItem.separator())

        // Add the Quit button
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q"))

        // Assign the menu to the status item
        statusItem?.menu = menu
    }

    @objc func printHello() {
        // This function is triggered when the "Hello" menu item is clicked.
        // It prints a message to the console for debugging.
        print("Hello from the menu!")
    }

    @objc func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
}







