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
import Blackbird

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    
    @Published var database: Blackbird.Database?
    private var databasePath: String
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        databasePath = documentsDirectory.appendingPathComponent("contacts.sqlite").path
        database = try! Blackbird.Database(path: databasePath)
    }
}

@main
struct ACS_ContactsApp: App {
    @Environment(\.scenePhase) private var phase
    @StateObject var databaseManager = DatabaseManager.shared

    init() {
        Aptabase.shared.initialize(
            appKey: AptabaseSecrets.appKey,
            with: InitOptions(host: AptabaseSecrets.host)
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(\.blackbirdDatabase, databaseManager.database)
        .backgroundTask(.appRefresh("contactListDownload")) {
            await fetchContactsInBackground()
        }
    }
}
