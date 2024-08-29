//
//  AppDelegate.swift
//  IP.Check
//
//  Created by Robby Ulrich on 8/29/24.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var customView: NSView?  // Change this back to NSView

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create a status item in the menu bar with a variable length
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set the title of the status item (the text displayed in the menu bar)
        if let button = statusItem?.button {
            button.title = "DN Dash"
        }

        // Create a new NSMenu instance to be displayed when the status item is clicked
        let menu = NSMenu()

        // Create a custom menu item that contains the CustomView for public IP
        let customViewItem = NSMenuItem()
        customView = CustomView(frame: NSRect(x: 0, y: 0, width: 380, height: 60)) // Increase height to 60
        customViewItem.view = customView
        menu.addItem(customViewItem)

        // Add a separator item
        menu.addItem(NSMenuItem.separator())

        // Add the "Set Home Country" menu item
        menu.addItem(NSMenuItem(title: "Set Home Country", action: #selector(openCountrySelector), keyEquivalent: "C"))

        // Add a separator item
        menu.addItem(NSMenuItem.separator())

        // Add the Quit button
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApplication), keyEquivalent: "q"))

        // Assign the menu to the status item
        statusItem?.menu = menu

        // Add this line to load the home country when the app starts
        (customView as? CustomView)?.loadHomeCountry()

        // Update status item title
        updateStatusItemTitle()
    }

    @objc func quitApplication() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func openCountrySelector() {
        let countries = ["United States", "China", "India", "Russia", "Brazil", "Japan", "Germany", "United Kingdom", "France", "Italy"]
        
        let alert = NSAlert()
        alert.messageText = "Select Home Country"
        alert.informativeText = "Choose your home country from the list below:"
        
        // Create a custom view to hold the icon and popup button
        let customView = NSView(frame: NSRect(x: 0, y: 0, width: 230, height: 30))
        
        // Create the location icon using SF Symbols
        let iconView = NSImageView(frame: NSRect(x: 0, y: 2, width: 25, height: 25))
        if let locationImage = NSImage(systemSymbolName: "location.fill", accessibilityDescription: "Location icon") {
            iconView.image = locationImage
            iconView.contentTintColor = .labelColor // This will make the icon adapt to light/dark mode
        }
        customView.addSubview(iconView)
        
        // Create the popup button
        let popUpButton = NSPopUpButton(frame: NSRect(x: 30, y: 0, width: 200, height: 25))
        popUpButton.addItems(withTitles: countries)
        
        // Set the default selected option to the current home country
        if let currentHomeCountry = UserDefaults.standard.string(forKey: "homeCountry"),
           let index = countries.firstIndex(of: currentHomeCountry) {
            popUpButton.selectItem(at: index)
        }
        
        customView.addSubview(popUpButton)
        
        alert.accessoryView = customView
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            if let selectedCountry = popUpButton.selectedItem?.title {
                print("Selected country: \(selectedCountry)")
                (self.customView as? CustomView)?.updateHomeCountry(selectedCountry)
                updateStatusItemTitle()
            }
        }
    }

    func updateStatusItemTitle() {
        print("Updating status item title")
        if let customView = customView as? CustomView {
            print("Current country: \(customView.currentCountry ?? "nil")")
            print("Home country: \(UserDefaults.standard.string(forKey: "homeCountry") ?? "nil")")
            
            if let publicCountry = customView.currentCountry,
               let homeCountry = UserDefaults.standard.string(forKey: "homeCountry") {
                let title = publicCountry == homeCountry ? ":)" : ":("
                print("Setting title to: \(title)")
                statusItem?.button?.title = title
            } else {
                print("Setting title to: DN Dash")
                statusItem?.button?.title = "DN Dash"
            }
        } else {
            print("CustomView is nil or not of type CustomView")
            statusItem?.button?.title = "DN Dash"
        }
    }
}






