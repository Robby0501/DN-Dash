//
//  IP_CheckApp.swift
//  IP.Check
//
//  Created by Robby Ulrich on 8/29/24.
//

import SwiftUI

@main
struct IPCheckerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView() // No main window, so we use an empty view
        }
    }
}

