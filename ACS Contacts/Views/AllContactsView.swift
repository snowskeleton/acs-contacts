//
//  ContactsView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData
import Blackbird



struct AllContactsView: View {
    @Environment(\.blackbirdDatabase) var db
    
    @State private var searchText: String = ""
    @State private var alertErrorTitle: String = "Default error title"
    @State private var alertErrorMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    @State private var showProgressView: Bool = false
    @State private var progressViewLabel: String = "Default progress label"
    @State private var progressViewProgress: Int = 0
    @State private var progressViewGoal: Int = 0
    
    @AppStorage("completedInitialDownload") var contactsDownloaded = false
    @AppStorage("isAppReviewTesting") var isTesting: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if showProgressView {
                    ProgressView(
                        value: Double(progressViewProgress),
                        total: Double(progressViewGoal),
                        label: {
                            HStack {
                                Spacer()
                                Text(progressViewLabel)
                                Spacer()
                            }
                        },
                        currentValueLabel: { Text("\(progressViewProgress) / \(progressViewGoal)")}
                    )
                    .progressViewStyle(.linear)
                }
                ListContactsView(searchText: $searchText)
                .refreshable { saveContactsToModelContext() }
                .searchable(text: $searchText)
                .onAppear { gatedFetchContacts() }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertErrorTitle),
                    message: Text(alertErrorMessage)
                )
            }
            .navigationBarTitle("Contacts")
            
        }
    }
    
    fileprivate func gatedFetchContacts() {
        guard !contactsDownloaded else { return }
        saveContactsToModelContext()
        contactsDownloaded = true
    }
    
    private func saveContactsToModelContext() {
        Task {
            if isTesting { return }
            progressViewLabel = "Downloading Contacts..."
            showProgressView = true
            let result = await fetchContacts { progress, goal, _ in
                progressViewProgress = progress
                progressViewGoal = goal
            }

            switch result {
            case .success(let contacts):
                progressViewLabel = "Saving Contacts..."
                await Contact.bulkInit(db!, contacts)
            case .failure(let error):
                print(error)
                progressViewLabel = "Download Failed"
                alertErrorTitle = "Fetch Error"
                alertErrorMessage = "Failed to Fetch Contacts.\n\(error.customMessage)"
                showAlert = true
            }
            
            showProgressView = false
        }
    }
}
