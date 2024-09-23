//
//  ACS_ContactsApp.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData

@main
struct ACS_ContactsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SwiftDataManager.shared.container)
    }
}
