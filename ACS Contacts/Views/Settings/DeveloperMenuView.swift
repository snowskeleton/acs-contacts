//
//  DeveloperMenuView.swift
//  OSTRich
//
//  Created by snow on 8/28/24.
//

import SwiftUI
import SwiftData

struct DeveloperMenuView: View {
    @Environment(\.modelContext) private var context

    @State private var showCrashConfirmation = false

    @AppStorage("fetchContactsPageSize") var pageSize = "500"
    @AppStorage("completedInitialDownload") var contactsDownloaded = false

    var body: some View {
        List {
            Section {
                TextField("Page size", text: $pageSize)
                    .keyboardType(.numberPad)
            }
            
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
                Button("Drop all tables", role: .destructive) {
                    try? ModelContainer().deleteAllData()
                    contactsDownloaded = false
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
