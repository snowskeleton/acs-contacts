//
//  ListContactsView.swift
//  ACS Contacts
//
//  Created by snow on 9/27/24.
//  https://stackoverflow.com/a/65186275/13919791
//


import SwiftUI
import SwiftData
import Blackbird

struct ListContactsView: View {
    @Environment(\.blackbirdDatabase) var db

    @BlackbirdLiveModels var contacts: Blackbird.LiveResults<Contact>
//    @BlackbirdLiveModels var phones: Blackbird.LiveResults<Phone>
    @Binding var searchText: String
    
    init(searchText: Binding<String>) {
        _searchText = searchText
        // this method is performant, but can't search phone numbers
        _contacts = BlackbirdLiveModels<Contact> { db in
//            if searchText.wrappedValue.isEmpty {
//                return try await Contact.read(from: db, orderBy: .ascending(\.$lastName))
//            } else {
                let queryText = "%" + searchText.wrappedValue.lowercased() + "%" // Search pattern with wildcards
                return try await Contact.read(from: db, sqlWhere: "LOWER(displayName) LIKE ? OR LOWER(fullName) LIKE ? ORDER BY lastName", queryText)
//            }
        }

        // this method can search phone numbers, but doesn't perform very well
//        _contacts = BlackbirdLiveModels<Contact> { try await Contact.read(from: $0, orderBy: .ascending(\.$lastName)) }
//        _phones = BlackbirdLiveModels<Phone> { try await Phone.read(from: $0) }
    }
    
    var presentableContacts: [Contact] {
        if searchText.isEmpty {
            return contacts.results
        } else {
//            let filteredPhones = phones.results.filter { phone in
//                phone.searchablePhoneNumber.lowercased().contains(searchText.lowercased())
//            }
            return contacts.results.filter { contact in
                let nameMatches = contact.displayName.lowercased().contains(searchText.lowercased())
//                let phoneMatches = filteredPhones.contains { $0.indvId == contact.indvId }
                return nameMatches //|| phoneMatches
            }
        }
    }
    let alphaRange = (0..<26).map({Character(UnicodeScalar("a".unicodeScalars.first!.value + $0)!)})

    var body: some View {
        ScrollView {
            ScrollViewReader { value in
                ZStack {
                    List {
                        ForEach(alphaRange, id: \.self) { letter in
                            let contactsWithLetter = contacts.results
                                .filter {
                                    ($0.lastName ?? $0.firstName ?? $0.displayName)
                                    .lowercased()
                                    .hasPrefix(letter.description)
                                }
                            if !contactsWithLetter.isEmpty {
                                Section(letter.description) {
                                    ForEach(contactsWithLetter, id: \.self) { contact in
                                        NavigationLink {
                                            SingleContactView(contact: contact)
                                        } label: {
                                            Text(contact.displayName)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    HStack {
                        Spacer()
                        VStack {
                            ForEach(0..<alphaRange.count, id: \.self) { idx in
                                Button("\(idx % 2 == 0 ? alphaRange[idx] : "\u{2022}")") {
                                    withAnimation {
                                        value.scrollTo(alphaRange[idx])
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
//        Button("Update All") {
//            Task {
//                await Contact.updateAll(db!, contacts.results)
//            }
//        }
    }
}
