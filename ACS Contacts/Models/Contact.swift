//
//  Contact.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import Blackbird

struct Contact: BlackbirdModel, Identifiable {
    static var primaryKey: [BlackbirdColumnKeyPath] = [ \.$indvId ]
    
    @BlackbirdColumn var indvId: Int
    @BlackbirdColumn var famId: Int?
    @BlackbirdColumn var familyPosition: String?
    @BlackbirdColumn var title: String?
    @BlackbirdColumn var firstName: String?
    @BlackbirdColumn var lastName: String?
    @BlackbirdColumn var middleName: String?
    @BlackbirdColumn var goesByName: String?
    @BlackbirdColumn var suffix: String?
    @BlackbirdColumn var pictureUrl: String?
    @BlackbirdColumn var statusSelected: String?
    @BlackbirdColumn var fullName: String?
    @BlackbirdColumn var friendlyName: String?
    @BlackbirdColumn var familyPictureUrl: String?
    @BlackbirdColumn var dateOfBirth: String?
    @BlackbirdColumn var memberStatus: String?
    @BlackbirdColumn var userIsLeaderOf: Bool?
    @BlackbirdColumn var isCRPending: Bool?
    
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

    init(from apiResponse: ContactList.Contact) {
        self.indvId = apiResponse.IndvId
        self.famId = apiResponse.FamId ?? apiResponse.PrimFamily
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
    }

    static public func bulkInit(_ db: Blackbird.Database, _ apiResponse: [ContactList.Contact]) async {
        do {
            try await db.transaction { core in
                for apiContact in apiResponse {
                    let contact = Contact(from: apiContact)
                    
                    try core.query(
            """
            INSERT INTO Contact (indvId, famId, familyPosition, title, firstName, lastName, middleName, goesByName, suffix, pictureUrl, statusSelected, fullName, friendlyName, familyPictureUrl, dateOfBirth, memberStatus, userIsLeaderOf, isCRPending)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT(indvId) DO UPDATE SET
                famId = excluded.famId,
                familyPosition = excluded.familyPosition,
                title = excluded.title,
                firstName = excluded.firstName,
                lastName = excluded.lastName,
                middleName = excluded.middleName,
                goesByName = excluded.goesByName,
                suffix = excluded.suffix,
                pictureUrl = excluded.pictureUrl,
                statusSelected = excluded.statusSelected,
                fullName = excluded.fullName,
                friendlyName = excluded.friendlyName,
                familyPictureUrl = excluded.familyPictureUrl,
                dateOfBirth = excluded.dateOfBirth,
                memberStatus = excluded.memberStatus,
                userIsLeaderOf = excluded.userIsLeaderOf,
                isCRPending = excluded.isCRPending
            """,
            contact.indvId, contact.famId, contact.familyPosition, contact.title, contact.firstName, contact.lastName, contact.middleName, contact.goesByName, contact.suffix, contact.pictureUrl, contact.statusSelected, contact.fullName, contact.friendlyName, contact.familyPictureUrl, contact.dateOfBirth, contact.memberStatus, contact.userIsLeaderOf, contact.isCRPending
                    )
                }
            }
            
        } catch { }
    }
}
