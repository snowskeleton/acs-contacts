//
//  ACS_ContactsApp.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData
import Aptabase

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
        .onChange(of: phase) { _, newPhase in
            if newPhase == .background {
                Task {
                    scheduleAppRefresh()
                }
            }
        }        .backgroundTask(.appRefresh("contactListDownload")) {
            await fetchContactsInBackground()
        }
    }
}
