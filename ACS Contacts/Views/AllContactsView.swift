//
//  ContactsView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData

struct AllContactsView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Contact.lastName) var contacts: [Contact]
    @State private var searchText: String = ""
    var presentableContacts: [Contact] {
        if searchText.isEmpty {
            return contacts
        } else if searchText.count > 0 && searchText.count < 3 {
            return []
        } else {
            return contacts.filter {
                $0.displayName.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @State private var alertErrorTitle: String = "Default error title"
    @State private var alertErrorMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    @State private var showProgressView: Bool = false
    @State private var progressViewProgress: Double = 0
    @State private var progressViewGoal: Double = 0
    
    @AppStorage("completedInitialDownload") var contactsDownloaded = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if showProgressView {
                    ProgressView(
                        value: progressViewProgress,
                        total: progressViewGoal,
                        label: {
                            HStack {
                                Spacer()
                                Text("Downloading Contacts...")
                                Spacer()
                            }
                        },
                        currentValueLabel: { Text("\(Int(progressViewProgress)) / \(Int(progressViewGoal))")}
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
            showProgressView = true
            
            let result = await fetchContacts { currentProgress, totalProgress, contacts in
                progressViewProgress = currentProgress
                progressViewGoal = totalProgress
                Task.detached {
                    for apiContact in contacts {
                        let actor = SwiftDataActor(modelContainer: SwiftDataManager.shared.container)
                        await actor.createContact(apiContact)
                    }
                }
            }
            
            switch result {
            case .success(let contacts):
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
    onProgressUpdate: @escaping (_ current: Double, _ total: Double, _ contacts: [ContactList.Contact]) -> Void
) async -> Result<[ContactList.Contact], RequestError> {
    guard let siteNumber = UserManager.shared.currentUser?.siteNumber else {
        return .failure(RequestError.custom("No site number"))
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
            
            onProgressUpdate(Double(pageIndex * pageSize), Double(totalPages * pageSize), contactsResponse.Page)
        case .failure(let error):
            return .failure(error)
        }
    }
    return .success(contacts)
}
