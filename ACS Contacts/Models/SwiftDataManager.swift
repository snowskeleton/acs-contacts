//
//  SwiftDataManager.swift
//  ACS Contacts
//
//  Created by snow on 8/24/24.
//

import Foundation
import SwiftData

public class SwiftDataManager {
    
    public static let shared = SwiftDataManager()
    
    public let container: ModelContainer = {
        let schema = Schema([
            Address.self,
            Contact.self,
            Email.self,
            Phone.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            do {
                NSLog("Failed to load current schema and config. Cleraing and trying again")
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()
}

@ModelActor
actor SwiftDataActor {
    func createContact(_ apiContact: ContactList.Contact) {
        let fetchDescriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { $0.indvId == apiContact.IndvId }
        )
        let contacts = try? modelContext.fetch(fetchDescriptor)
        var contact: Contact
        
        if let finalContact = (contacts ?? []).first {
            contact = finalContact
            contact.update(with: apiContact)
        } else {
            contact = Contact(from: apiContact)
        }
        modelContext.insert(contact)
        try! modelContext.save()
    }
    
    func createContact(_ apiContact: IndividualContactResponse) {
        let fetchDescriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { $0.indvId == apiContact.IndvId }
        )
        let contacts = try? modelContext.fetch(fetchDescriptor)
        var contact: Contact

        if let finalContact = (contacts ?? []).first {
            contact = finalContact
            contact.update(with: apiContact)
        } else {
            contact = Contact(from: apiContact)
        }
        contact.addresses = apiContact.Addresses.map {
            createAddress($0)
        }
        contact.phones = apiContact.Phones.map {
            createPhone($0)
        }
        contact.emails = apiContact.Emails.map {
            createEmail($0)
        }
        modelContext.insert(contact)
        try! modelContext.save()
    }
    
    func createAddress(_ apiAddress: IndividualContactResponse.Address) -> Address {
        let fetchDescriptor = FetchDescriptor<Address>(
            predicate: #Predicate<Address> { $0.addrId == apiAddress.AddrId }
        )
        let addresses = try? modelContext.fetch(fetchDescriptor)
        var address: Address
        
        if let finalAddress = (addresses ?? []).first {
            address = finalAddress
            address.update(with: apiAddress)
        } else {
            address = Address(from: apiAddress)
        }
        return address
    }
    
    func createPhone(_ apiPhone: IndividualContactResponse.Phone) -> Phone {
        let fetchDescriptor = FetchDescriptor<Phone>(
            predicate: #Predicate<Phone> { $0.phoneId == apiPhone.PhoneId }
        )
        let phones = try? modelContext.fetch(fetchDescriptor)
        var phone: Phone
        
        if let finalPhone = (phones ?? []).first {
            phone = finalPhone
            phone.update(with: apiPhone)
        } else {
            phone = Phone(from: apiPhone)
        }
        return phone
    }
    
    func createEmail(_ apiEmail: IndividualContactResponse.Email) -> Email {
        let fetchDescriptor = FetchDescriptor<Email>(
            predicate: #Predicate<Email> { $0.emailId == apiEmail.EmailId }
        )
        let emails = try? modelContext.fetch(fetchDescriptor)
        var email: Email
        
        if let finalEmail = (emails ?? []).first {
            email = finalEmail
            email.update(with: apiEmail)
        } else {
            email = Email(from: apiEmail)
        }
        return email
    }
}
