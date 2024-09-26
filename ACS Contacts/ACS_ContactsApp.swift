//
//  ACS_ContactsApp.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData
import Aptabase
import Blackbird

@main
struct ACS_ContactsApp: App {
    @Environment(\.scenePhase) private var phase
    @StateObject var database: Blackbird.Database
    
    init() {
        Aptabase.shared.initialize(
            appKey: AptabaseSecrets.appKey,
            with: InitOptions(host: AptabaseSecrets.host)
        )
        
        // Get the document directory path
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // Define the path for the database file
        let databasePath = documentsDirectory.appendingPathComponent("contacts.sqlite").path
        
        // Initialize the database with the file path
        _database = StateObject(wrappedValue: try! Blackbird.Database(path: databasePath))

    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase == .background {
                scheduleAppRefresh()
            }
        }
        .backgroundTask(.appRefresh("contactListDownload")) {
            await fetchContactsInBackground()
        }
        .environment(\.blackbirdDatabase, database)
    }
}
