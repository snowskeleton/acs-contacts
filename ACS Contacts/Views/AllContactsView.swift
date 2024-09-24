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
        searchText.isEmpty ?
        contacts :
        contacts.filter {
            ($0.firstName ?? "").lowercased().contains(searchText.lowercased()) ||
            ($0.lastName ?? "").lowercased().contains(searchText.lowercased())
        }
    }
    
    @State private var alertErrorTitle: String = "Default error title"
    @State private var alertErrorMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Button("Fetch Contacts") { fetchContacts() }
                List(presentableContacts, id: \.self) { contact in
                    NavigationLink {
                        SingleContactView(contact: contact)
                    } label: {
                        Text(contact.displayName)
                    }
                }
                .searchable(text: $searchText)
                .onAppear { fetchContacts() }
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
    
    fileprivate func fetchContacts() {
        Task {
            // Assume `siteNumber` is saved in the UserManager from login
            guard let siteNumber = UserManager.shared.currentUser?.siteNumber else { return }
            
            var pageIndex = 0
            var totalPages = Int.max
            
            while pageIndex < totalPages {
                let contactsResult = await ACSService().getContacts(siteNumber: siteNumber, pageIndex: pageIndex)
                
                switch contactsResult {
                case .success(let contactsResponse):
                    await saveContactsToModelContext(contactsResponse.Page)
                    
                    totalPages = contactsResponse.PageCount
                    
                    pageIndex += 1
                    
                case .failure(let error):
                    print(error)
                    alertErrorTitle = "Failed to Fetch Contacts"
                    alertErrorMessage = error.customMessage
                    showAlert = true
                    return
                }
            }
        }
    }
    private func saveContactsToModelContext(_ contacts: [ContactList.Contact]) async {
        for apiContact in contacts {
            let newContact = Contact.createOrUpdate(from: apiContact)
            context.insert(newContact)
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save contacts: \(error)")
            alertErrorTitle = "Save Error"
            alertErrorMessage = "Failed to save contacts."
            showAlert = true
        }
    }}
