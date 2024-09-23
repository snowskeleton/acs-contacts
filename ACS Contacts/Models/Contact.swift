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
    var firstName: String
    var lastName: String
    var middleName: String?
    var goesByName: String?
    var suffix: String?
    var pictureUrl: String?
    var statusSelected: String?
    
    init(
        indvId: Int,
        famId: Int,
        familyPosition: String? = nil,
        title: String? = nil,
        firstName: String,
        lastName: String,
        middleName: String? = nil,
        goesByName: String? = nil,
        suffix: String? = nil,
        pictureUrl: String? = nil,
        statusSelected: String? = nil
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
}
