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
    @Environment(\.modelContext) private var context
    @Environment(\.blackbirdDatabase) var db
    
    @BlackbirdLiveModels({ try await Contact.read(from: $0, orderBy: .ascending(\.$lastName)) }) var contacts
    
    @State private var searchText: String = ""
    var presentableContacts: [Contact] {
        if searchText.isEmpty {
            return contacts.results
        } else if searchText.count > 0 && searchText.count < 3 {
            return []
        } else {
            return contacts.results.filter {
                $0.displayName.lowercased().contains(searchText.lowercased()) //||
//                $0.phones.contains(where: { $0.searchablePhoneNumber.contains(searchText.lowercased()) })
            }
        }
    }
    
    @State private var alertErrorTitle: String = "Default error title"
    @State private var alertErrorMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    @State private var showProgressView: Bool = false
    @State private var progressViewLabel: String = "Downloading Contacts..."
    @State private var progressViewProgress: Int = 0
    @State private var progressViewGoal: Int = 0
    
    @AppStorage("completedInitialDownload") var contactsDownloaded = false
    
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
                List(presentableContacts, id: \.indvId) { contact in
                    NavigationLink {
                        SingleContactView(contact: contact)
                    } label: {
                        Text(contact.displayName)
                    }
                }
                .refreshable {
                    saveContactsToModelContext()
                }
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
            progressViewLabel = "Downloading Contacts..."
            showProgressView = true
            
            let result = await fetchContacts { currentProgress, totalProgress, _ in
                progressViewProgress = currentProgress
                progressViewGoal = totalProgress
            }
            
            switch result {
            case .success(let contacts):
                progressViewLabel = "Saving Contacts..."
                var progressCount = 0
                for apiContact in contacts {
                    do {
                        progressCount += 1
                        progressViewProgress = progressCount
                        let contact = Contact(from: apiContact)
                        try await contact.write(to: db!)
                    } catch {
                        print("Failed to create contact: \(error)")
                    }
                }
                print("success! we have \(contacts.count) objects")
            case .failure(let error):
                print(error)
                alertErrorTitle = "Fetch Error"
                alertErrorMessage = "Failed to Fetch Contacts.\n\(error.customMessage)"
                showAlert = true
            }
            
            showProgressView = false
        }
    }
}

func fetchContacts(
    onProgressUpdate: @escaping (_ current: Int, _ total: Int, _ contacts: [ContactList.Contact]) -> Void
) async -> Result<[ContactList.Contact], RequestError> {
    guard let siteNumber = UserManager.shared.currentUser?.siteNumber else {
        return .failure(RequestError.custom("No site number"))
    }
    
    // tell calling function how many records we're aiming for
    var totalRecords: Int = 0
    let contactsResult = await ACSService().getContacts(
        siteNumber: siteNumber,
        pageIndex: 1,
        pageSize: 1
    )
    switch contactsResult {
    case .success(let contactsResponse):
        totalRecords = contactsResponse.PageCount
        onProgressUpdate(0, totalRecords, [])
    case .failure(let error):
        return .failure(error)
    }

    var pageSize = UserDefaults.standard.integer(forKey: "fetchContactsPageSize")
    if pageSize == 0 { pageSize = 500 }
    
    var pageIndex = 0
    var totalPages = Int.max
    var contacts: [ContactList.Contact] = []
    
    while pageIndex < totalPages {
        let contactsResult = await ACSService().getContacts(
            siteNumber: siteNumber,
            pageIndex: pageIndex,
            pageSize: pageSize
        )
        
        switch contactsResult {
        case .success(let contactsResponse):
            contacts.append(contentsOf: contactsResponse.Page)
            totalPages = contactsResponse.PageCount
            pageIndex += 1
            
            onProgressUpdate(pageIndex * pageSize, totalRecords, contactsResponse.Page)
        case .failure(let error):
            return .failure(error)
        }
    }
    return .success(contacts)
}
