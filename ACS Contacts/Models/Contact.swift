//
//  Contact.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import SwiftData

@Model
class Contact: Identifiable {
    @Attribute(.unique)
    var indvId: Int
    var famId: Int
    var familyPosition: String?
    var title: String?
    var firstName: String?
    var lastName: String?
    var middleName: String?
    var goesByName: String?
    var suffix: String?
    var pictureUrl: String?
    var statusSelected: String?
    
    var fullName: String?
    var friendlyName: String?
    var familyPictureUrl: String?
    var dateOfBirth: String?
    var memberStatus: String?
    var userIsLeaderOf: Bool = false
    var isCRPending: Bool = false
    
    var addresses: [Address] = []
    var emails: [Email] = []
    var phones: [Phone] = []
    
    var displayName: String {
        if let name = friendlyName, !name.isEmpty {
            return name
        } else if let firstName, let lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName {
            return firstName
        } else {
            return "NoName: \(indvId)"
        }
    }
    
    init(
        indvId: Int,
        famId: Int,
        familyPosition: String? = nil,
        title: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        middleName: String? = nil,
        goesByName: String? = nil,
        suffix: String? = nil,
        pictureUrl: String? = nil,
        statusSelected: String? = nil,
        
        fullName: String? = nil,
        friendlyName: String? = nil,
        familyPictureUrl: String? = nil,
        dateOfBirth: String? = nil,
        memberStatus: String? = nil,
        userIsLeaderOf: Bool = false,
        isCRPending: Bool = false

    ) {
        self.indvId = indvId
        self.famId = famId
        self.familyPosition = familyPosition
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.middleName = middleName
        self.goesByName = goesByName
        self.suffix = suffix
        self.pictureUrl = pictureUrl
        self.statusSelected = statusSelected
        
        self.fullName = fullName
        self.friendlyName = friendlyName
        self.familyPictureUrl = familyPictureUrl
        self.dateOfBirth = dateOfBirth
        self.memberStatus = memberStatus
        self.userIsLeaderOf = userIsLeaderOf
        self.isCRPending = isCRPending

    }
    
    init(from apiResponse: ContactList.Contact) {
        self.indvId = apiResponse.IndvId
        self.famId = apiResponse.FamId
        self.familyPosition = apiResponse.FamilyPosition
        self.title = apiResponse.Title
        self.firstName = apiResponse.FirstName
        self.lastName = apiResponse.LastName
        self.middleName = apiResponse.MiddleName
        self.goesByName = apiResponse.GoesByName
        self.suffix = apiResponse.Suffix
        self.pictureUrl = apiResponse.PictureUrl
        self.statusSelected = apiResponse.StatusSelected
    }
    
    
    init(from apiResponse: IndividualContactResponse) {
        self.indvId = apiResponse.IndvId
        self.famId = apiResponse.PrimFamily
        self.familyPosition = apiResponse.FamilyPosition
        self.title = apiResponse.Title
        self.firstName = apiResponse.FirstName
        self.lastName = apiResponse.LastName
        self.middleName = apiResponse.MiddleName
        self.goesByName = apiResponse.GoesbyName
        self.suffix = apiResponse.Suffix
        self.fullName = apiResponse.FullName
        self.friendlyName = apiResponse.FriendlyName
        self.pictureUrl = apiResponse.PictureUrl
        self.familyPictureUrl = apiResponse.FamilyPictureUrl
        self.dateOfBirth = apiResponse.DateOfBirth
        self.memberStatus = apiResponse.MemberStatus
        self.userIsLeaderOf = apiResponse.UserIsLeaderOf
        self.isCRPending = apiResponse.IsCRPending
        self.addresses = apiResponse.Addresses.map { Address(from: $0) }
        self.emails = apiResponse.Emails.map { Email(from: $0) }
        self.phones = apiResponse.Phones.map { Phone(from: $0) }
    }
    
    
    func update(with apiResponse: ContactList.Contact) {
        self.indvId = apiResponse.IndvId
        self.famId = apiResponse.FamId
        self.familyPosition = apiResponse.FamilyPosition
        self.title = apiResponse.Title
        self.firstName = apiResponse.FirstName
        self.lastName = apiResponse.LastName
        self.middleName = apiResponse.MiddleName
        self.goesByName = apiResponse.GoesByName
        self.suffix = apiResponse.Suffix
        self.pictureUrl = apiResponse.PictureUrl
        self.statusSelected = apiResponse.StatusSelected
    }
    
    @MainActor
    func update(with apiResponse: IndividualContactResponse) {
        self.indvId = apiResponse.IndvId
        self.famId = apiResponse.PrimFamily
        self.familyPosition = apiResponse.FamilyPosition
        self.title = apiResponse.Title
        self.firstName = apiResponse.FirstName
        self.lastName = apiResponse.LastName
        self.middleName = apiResponse.MiddleName
        self.goesByName = apiResponse.GoesbyName
        self.suffix = apiResponse.Suffix
        self.fullName = apiResponse.FullName
        self.friendlyName = apiResponse.FriendlyName
        self.pictureUrl = apiResponse.PictureUrl
        self.familyPictureUrl = apiResponse.FamilyPictureUrl
        self.dateOfBirth = apiResponse.DateOfBirth
        self.memberStatus = apiResponse.MemberStatus
        self.userIsLeaderOf = apiResponse.UserIsLeaderOf
        self.isCRPending = apiResponse.IsCRPending
        self.addresses = apiResponse.Addresses.map { Address.createOrUpdate(from: $0) }
        self.emails = apiResponse.Emails.map { Email.createOrUpdate(from: $0) }
        self.phones = apiResponse.Phones.map { Phone.createOrUpdate(from: $0) }
    }

    
    @MainActor static func createOrUpdate(
        from apiContact: ContactList.Contact
    ) -> Contact {
        let fetchDescriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { $0.indvId == apiContact.IndvId }
        )
        let context = SwiftDataManager.shared.container.mainContext
        let contacts = try? context.fetch(fetchDescriptor)
        
        if let finalContact = (contacts ?? []).first {
            finalContact.update(with: apiContact)
            return finalContact
        } else {
            return .init(from: apiContact)
        }
    }
    
    @MainActor static func createOrUpdate(
        from apiContact: IndividualContactResponse
    ) -> Contact {
        let fetchDescriptor = FetchDescriptor<Contact>(
            predicate: #Predicate<Contact> { $0.indvId == apiContact.IndvId }
        )
        let context = SwiftDataManager.shared.container.mainContext
        let contacts = try? context.fetch(fetchDescriptor)
        
        if let finalContact = (contacts ?? []).first {
            finalContact.update(with: apiContact)
            return finalContact
        } else {
            return .init(from: apiContact)
        }
    }
}
