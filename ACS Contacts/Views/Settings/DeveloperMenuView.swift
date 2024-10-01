//
//  DeveloperMenuView.swift
//  ACS Contacts
//
//  Created by snow on 8/28/24.
//

import SwiftUI
import SwiftData

struct DeveloperMenuView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.blackbirdDatabase) var db

    @State private var showCrashConfirmation = false

    @AppStorage("fetchContactsPageSize") var pageSize = "500"
    @AppStorage("completedInitialDownload") var contactsDownloaded = false
    @AppStorage("completedFullUpdate") var completedFullUpdate = false
    @AppStorage("isAppReviewTesting") var isTesting: Bool = false

    var body: some View {
        List {
            Section {
                TextField("Page size", text: $pageSize)
                    .keyboardType(.numberPad)
            }
            
            Toggle("Update all contacts in background", isOn: $contactsDownloaded)
            Toggle("Disable network calls for testing purposes", isOn: $isTesting)

            Section("Actions") {
                Button("Crash!") { showCrashConfirmation = true }
                    .confirmationDialog(
                        "Crash car into a bridge",
                        isPresented: $showCrashConfirmation) {
                            Button(
                                "Watch and let it burn",
                                role: .destructive ) {
                                    fatalError()
                                }
                        }
                Button("Clear All Data", role: .destructive) {
                    Task {
                        do {
                            try await db!.execute("DELETE FROM Contact;")
                            try await db!.execute("DELETE FROM Address;")
                            try await db!.execute("DELETE FROM Email;")
                            try await db!.execute("DELETE FROM Phone;")
                            
                            contactsDownloaded = false
//                            completedFullUpdate = false
                        } catch {
                            print("Failed to delete data: \(error)")
                        }
                    }
                }
            }
            
        }
        .onAppear {
            Analytics.track(.openedDeveloperMenu)
        }
        .navigationTitle("Developer")
    }
}

#Preview {
    DeveloperMenuView()
}
