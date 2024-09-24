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
        .onChange(of: phase) { _, newPhase in
            if newPhase == .background {
                scheduleAppRefresh()
            }
        }
        .backgroundTask(.appRefresh("contactListDownload")) {
            await fetchContactsInBackground()
        }
        .modelContainer(SwiftDataManager.shared.container)
    }
}
