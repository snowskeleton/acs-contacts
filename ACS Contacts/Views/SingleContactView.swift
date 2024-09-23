//
//  SingleContactView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI

struct SingleContactView: View {
    @State var contact: Contact
    
    @State private var errorMessage: String?
    @State private var isLoading = false
    
    @AppStorage("siteNumber") var siteNumber: String = ""

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading contact...")
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                HStack {
                    HStack {
                        ProfilePhoto(contact: contact)
                        Text("\(contact.friendlyName ?? "Unknown")")
                            .font(.title)
                    }
                    Spacer()
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
                                HStack {
                                    Text(phone.phoneNumber ?? "Unknown")
                                    Spacer()
                                    if phone.preferred == true && contact.phones.count > 1 {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    if !contact.addresses.isEmpty {
                        Section("Address\(contact.addresses.count > 1 ? "es" : "")") {
                            ForEach(contact.addresses, id: \.self) { address in
                                HStack {
                                    AddressTextView(address: address)
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
        }
        .onAppear {
            fetchContact()
        }
        .navigationTitle("Contact Details")
    }
    
    private func fetchContact() {
        isLoading = true
        Task {
            let result = await ACSService().getIndividualContact(siteNumber: siteNumber, indvId: contact.indvId.description)
            
            switch result {
            case .success(let contactResponse):
                contact = Contact.createOrUpdate(from: contactResponse)
            case .failure(let error):
                self.errorMessage = "Failed to fetch contact: \(error.customMessage)"
            }
            
            isLoading = false
        }
    }
}

struct AddressTextView: View {
    var address: Address
    var addressString: String {
        var starterString = ""
        if let line1 = address.addressLine1, !line1.isEmpty {
            starterString += "\(line1)"
        }
        
        if let line2 = address.addressLine2, !line2.isEmpty {
            starterString += "\n\(line2)"
        }
        
        if let cityStateZip = address.cityStateZip, !cityStateZip.isEmpty {
            starterString += "\n\(cityStateZip)"
        }
        
        if let country = address.country, !country.isEmpty {
            starterString += "\n\(country)"
        }
        
        return starterString
    }
    
    var body: some View {
        Text(addressString)
    }
}
