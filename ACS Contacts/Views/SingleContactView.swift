//
//  SingleContactView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import ContactsUI
import Blackbird

struct SingleContactView: View {
    @Environment(\.blackbirdDatabase) var db
    
    @BlackbirdLiveModel var contact: Contact?
    
    @BlackbirdLiveModels<Contact> var family: Blackbird.LiveResults<Contact>
    @BlackbirdLiveModels<Address> var addresses: Blackbird.LiveResults<Address>
    @BlackbirdLiveModels<Phone> var phones: Blackbird.LiveResults<Phone>
    @BlackbirdLiveModels<Email> var emails: Blackbird.LiveResults<Email>

    init(contact: Contact) {
        _contact = contact.liveModel
        _addresses = BlackbirdLiveModels<Address>({ try await Address.read(from: $0, matching: \.$indvId == contact.indvId, orderBy: .ascending(\.$addrId)) })
        _phones = BlackbirdLiveModels<Phone>({ try await Phone.read(from: $0, matching: \.$indvId == contact.indvId, orderBy: .ascending(\.$phoneId)) })
        _emails = BlackbirdLiveModels<Email>({ try await Email.read(from: $0, matching: \.$indvId == contact.indvId, orderBy: .ascending(\.$emailId)) })
        _family = BlackbirdLiveModels<Contact>({
            try await Contact.read(
                from: $0,
                matching: \.$famId == contact.famId && \.$indvId != contact.indvId,
                orderBy: .ascending(\.$firstName)
            )
        })
    }
    
    @AppStorage("isAppReviewTesting") var isTesting: Bool = false
    @AppStorage("siteNumber") var siteNumber: String = ""
    @State private var addedContact = false
    
    @State private var alertAlertTitle: String = "Default error title"
    @State private var alertAlertMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    @State private var showProgressView: Bool = false
    
    var body: some View {
        VStack {
            if let contact {
                HStack {
                    if !(contact.pictureUrl ?? "").isEmpty {
                        ProfilePhoto(contact: contact)
                    }
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
                    if let firstName = contact.firstName, !firstName.isEmpty {
                        Section {
                            Text(firstName)
                        }
                    }
                    if let middleName = contact.middleName, !middleName.isEmpty {
                        Section {
                            Text(middleName)
                        }
                    }
                    if let lastName = contact.lastName, !lastName.isEmpty {
                        Section {
                            Text(lastName)
                        }
                    }
                    if let friendlyName = contact.friendlyName,
                       !friendlyName.isEmpty,
                       friendlyName != contact.displayName {
                        Section {
                            Text(friendlyName)
                        }
                    }
                    if let dateOfBirth = contact.dateOfBirth, !dateOfBirth.isEmpty {
                        Section("Birthday") {
                            Text("Date of Birth: \(dateOfBirth)")
                        }
                    }
                    
                    if !phones.results.isEmpty {
                        Section("Phone\(phones.results.count > 1 ? "s" : "")") {
                            ForEach(phones.results, id: \.self) { phone in
                                if let number = phone.phoneNumber {
                                    Button {
                                        UIPasteboard.general.string = number
                                    } label: {
                                        HStack {
                                            Text(number)
                                            Spacer()
                                            if phone.preferred == true && phones.results.count > 1 {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    if !addresses.results.isEmpty {
                        Section(
                            "Address\(addresses.results.count > 1 ? "es" : "")"
                        ) {
                            ForEach(addresses.results, id: \.self) { address in
                                HStack {
                                    Text(address.addressString)
                                    Spacer()
                                    if address.activeAddress == true && addresses.results.count > 1 {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    if !emails.results.isEmpty {
                        Section("Email\(emails.results.count > 1 ? "s" : "")") {
                            ForEach(emails.results, id: \.self) { email in
                                HStack {
                                    Text(email.email ?? "Unknown")
                                    Spacer()
                                    if email.preferred == true && emails.results.count > 1 {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                    
                    if !family.results.isEmpty {
                        Section("Family Member\(family.results.count > 1 ? "s" : "")") {
                            ForEach(family.results, id: \.self) { familyMember in
                                NavigationLink {
                                    SingleContactView(contact: familyMember)
                                } label: {
                                    Text(familyMember.displayName)
                                }
                            }
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            fetchContact()
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
        Task {
            if isTesting { return }
            
            if let contact {
                let result = await ACSService().getIndividualContact(siteNumber: siteNumber, indvId: contact.indvId.description)
                
                switch result {
                case .success(let contactResponse):
                    await contact.update(db!, contactResponse)
                case .failure(let error):
                    alertAlertTitle = "Failed to fetch contact"
                    alertAlertMessage = error.customMessage
                    showAlert = true
                }
            } else {
                print("we have a problem")
            }
        }
    }
    
    private func addContact() {
        Task {
            if let contact {
                withAnimation {
                    addedContact = true
                }
                
                let store = CNContactStore()
                let saveableContact = CNMutableContact()
                
                saveableContact.givenName = contact.firstName ?? ""
                saveableContact.middleName = contact.middleName ?? ""
                saveableContact.familyName = contact.lastName ?? ""
                
                saveableContact.phoneNumbers = phones.results.filter {
                    $0.phoneNumber != nil
                }.map {
                    CNLabeledValue(
                        label: $0.phoneType != nil ? $0.phoneType : CNLabelPhoneNumberMobile,
                        value: CNPhoneNumber(stringValue: $0.phoneNumber!)
                    )
                }
                
                saveableContact.postalAddresses = addresses.results.filter {
                    $0.addressLine1 != nil
                }.map { address in
                    let postalAddress = CNMutablePostalAddress()
                
                    postalAddress.street = [
                        address.addressLine1,
                        address.addressLine2
                    ]
                        .compactMap { $0 }
                        .joined(separator: "\n")
                    postalAddress.city = address.city ?? ""
                    postalAddress.state = address.state ?? ""
                    postalAddress.postalCode = address.zipcode ?? ""
                    postalAddress.country = address.country ?? ""
                
                    return CNLabeledValue(
                        label: address.addrType ?? CNLabelHome,
                        value: postalAddress
                    )
                }
                
                saveableContact.emailAddresses = emails.results.filter {
                    $0.email != nil
                }.map { email in
                    CNLabeledValue(
                        label: email.emailType ?? CNLabelHome,
                        value: email.email! as NSString
                    )
                }
                
                if let pictureUrlString = contact.pictureUrl,
                   let pictureUrl = URL(string: pictureUrlString),
                   let imageData = await fetchImageData(from: pictureUrl) {
                    saveableContact.imageData = imageData
                }
                
                let saveRequest = CNSaveRequest()
                saveRequest.add(saveableContact, toContainerWithIdentifier: nil)
                try? store.execute(saveRequest)
                
                alertAlertTitle = "Contact Saved!"
                alertAlertMessage = ""
                showAlert = true
            }
        }
    }
}


private func fetchImageData(from url: URL) async -> Data? {
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    } catch {
        print("Failed to fetch image data: \(error)")
        return nil
    }
}
