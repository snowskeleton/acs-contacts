//
//  SingleContactView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import ContactsUI

struct SingleContactView: View {
    @State var contact: Contact
    
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    @AppStorage("siteNumber") var siteNumber: String = ""
    @State private var addedContact = false
    
    @State private var alertAlertTitle: String = "Default error title"
    @State private var alertAlertMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    @State private var showProgressView: Bool = false

    var body: some View {
        VStack {
            HStack {
                ProfilePhoto(contact: contact)
                Text(contact.displayName)
                    .font(.title)
                Spacer()
                Button {
                    addContact()
                } label: {
                    Image(systemName:
                            addedContact
                          ? "person.crop.circle.fill.badge.checkmark"
                          : "person.crop.circle.fill.badge.plus"
                    )
                    .font(.title)
                }
            }
            .padding()
            List {
                if let dateOfBirth = contact.dateOfBirth, !dateOfBirth.isEmpty {
                    Section("Birthday") {
                        Text("Date of Birth: \(dateOfBirth)")
                    }
                }
                
                if !contact.phones.isEmpty {
                    Section("Phone\(contact.phones.count > 1 ? "s" : "")") {
                        ForEach(contact.phones, id: \.self) { phone in
                            if let number = phone.phoneNumber {
                                Button {
                                    UIPasteboard.general.string = number
                                } label: {
                                    HStack {
                                        Text(number)
                                        Spacer()
                                        if phone.preferred == true && contact.phones.count > 1 {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                if !contact.addresses.isEmpty {
                    Section("Address\(contact.addresses.count > 1 ? "es" : "")") {
                        ForEach(contact.addresses, id: \.self) { address in
                            HStack {
                                Text(address.addressString)
                                Spacer()
                                if address.activeAddress == true && contact.addresses.count > 1 {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                if !contact.emails.isEmpty {
                    Section("Email\(contact.emails.count > 1 ? "s" : "")") {
                        ForEach(contact.emails, id: \.self) { email in
                            HStack {
                                Text(email.email ?? "Unknown")
                                Spacer()
                                if email.preferred == true && contact.emails.count > 1 {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchContact()
        }
        .overlay {
            if showProgressView {
                ProgressView()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertAlertTitle),
                message: Text(alertAlertMessage)
            )
        }
        .navigationTitle("Contact Details")
    }
    
    private func fetchContact() {
        showProgressView = true
        Task {
            let result = await ACSService().getIndividualContact(siteNumber: siteNumber, indvId: contact.indvId.description)
            
            switch result {
            case .success(let contactResponse):
                contact = Contact.createOrUpdate(from: contactResponse)
            case .failure(let error):
                alertAlertTitle = "Failed to fetch contact"
                alertAlertMessage = error.customMessage
                showAlert = true
            }
            
            showProgressView = false
        }
    }
    
    private func addContact() {
        withAnimation {
            addedContact = true
        }
        
        let store = CNContactStore()
        let saveableContact = CNMutableContact()
        
        saveableContact.givenName = contact.firstName ?? ""
        saveableContact.middleName = contact.middleName ?? ""
        saveableContact.familyName = contact.lastName ?? ""
        
        saveableContact.phoneNumbers = contact.phones.filter {
            $0.phoneNumber != nil
        }.map {
            CNLabeledValue(
                label: $0.phoneType != nil ? $0.phoneType : "mobile",
                value: CNPhoneNumber(stringValue: $0.phoneNumber!)
            )
        }
        //        saveableContact.postalAddresses =
        
        let saveRequest = CNSaveRequest()
        saveRequest.add(saveableContact, toContainerWithIdentifier: nil)
        try? store.execute(saveRequest)
        
        alertAlertTitle = "Contact Saved!"
        alertAlertMessage = ""
        showAlert = true
    }
}
