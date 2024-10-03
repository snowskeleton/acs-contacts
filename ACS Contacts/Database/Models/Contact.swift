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
    @BlackbirdColumn var displayName: String
    @BlackbirdColumn var lastUpdated: Date?
    @BlackbirdColumn var isFullyUpdated: Bool = false

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
        self.displayName = {
            if let firstName = (apiResponse.GoesByName ?? apiResponse.FirstName), let lastName = apiResponse.LastName {
                return "\(firstName) \(lastName)"
            } else if let firstName = apiResponse.FirstName {
                return firstName
            } else {
                return "NoName: \(apiResponse.IndvId)"
            }
        }()
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
        self.displayName = {
            if let firstName = (apiResponse.GoesbyName ?? apiResponse.FirstName), let lastName = apiResponse.LastName {
                return "\(firstName) \(lastName)"
            } else if let name = apiResponse.FriendlyName, !name.isEmpty {
                return name
            } else if let firstName = apiResponse.FirstName {
                return firstName
            } else {
                return "NoName: \(apiResponse.IndvId)"
            }
        }()

        if UserDefaults.standard.bool(forKey: "switchPhotosWithCats") {
            self.pictureUrl = synchronousCatPhotoURL()
        } else {
            self.pictureUrl = apiResponse.PictureUrl
        }
        self.familyPictureUrl = apiResponse.FamilyPictureUrl
        self.dateOfBirth = apiResponse.DateOfBirth
        self.memberStatus = apiResponse.MemberStatus
        self.userIsLeaderOf = apiResponse.UserIsLeaderOf
        self.isCRPending = apiResponse.IsCRPending
        self.lastUpdated = Date()
        self.isFullyUpdated = true
    }
    
    func update(_ db: Blackbird.Database, _ apiResponse: IndividualContactResponse) async {
        do {
            let contact = Contact(from: apiResponse)
            try await contact.write(to: db)
            
            for remoteAddress in apiResponse.Addresses {
                let address = Address(from: remoteAddress, for: contact.indvId)
                try await address.write(to: db)
            }
            
            for remoteEmail in apiResponse.Emails {
                let email = Email(from: remoteEmail, for: contact.indvId)
                try await email.write(to: db)
            }
            
            for remotePhone in apiResponse.Phones {
                let phone = Phone(from: remotePhone, for: contact.indvId)
                try await phone.write(to: db)
            }
            
        } catch {
            print("Failed to create contact: \(error)")
        }
    }

    static public func bulkInit(_ db: Blackbird.Database, _ apiResponse: [ContactList.Contact]) async {
        do {
            try await db.transaction { core in
                for apiContact in apiResponse {
                    let contact = Contact(from: apiContact)
                    
                    try core.query(
                        """
                        INSERT INTO Contact (
                            indvId, famId, familyPosition, title, firstName, lastName, middleName, 
                            goesByName, suffix, pictureUrl, statusSelected, fullName, friendlyName, 
                            familyPictureUrl, dateOfBirth, memberStatus, userIsLeaderOf, isCRPending, displayName
                        ) 
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
                            isCRPending = excluded.isCRPending,
                            displayName = excluded.displayName
                        """,
                        contact.indvId, contact.famId, contact.familyPosition, contact.title,
                        contact.firstName, contact.lastName, contact.middleName, contact.goesByName,
                        contact.suffix, contact.pictureUrl, contact.statusSelected, contact.fullName,
                        contact.friendlyName, contact.familyPictureUrl, contact.dateOfBirth,
                        contact.memberStatus, contact.userIsLeaderOf, contact.isCRPending, contact.displayName
                    )
                }
            }
        } catch { }
    }
}

extension Contact {
    @MainActor
    static public func updateAll(_ db: Blackbird.Database, _ contacts: [Contact]) async {
        if let siteNumber = UserDefaults.standard.string(forKey: "siteNumber") {
            for contact in contacts {
                let result = await ACSService().getIndividualContact(siteNumber: siteNumber, indvId: contact.indvId.description)
                
                switch result {
                case .success(let contactResponse):
                    await contact.update(db, contactResponse)
                case .failure(let error):
                    print(error)
                }
            }
        } else {
            print("No site number")
        }
    }
}
