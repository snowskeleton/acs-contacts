//
//  Email.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import Blackbird

struct Email: BlackbirdModel, Identifiable {
    static var primaryKey: [BlackbirdColumnKeyPath] = [ \.$emailId ]
    
    //Contact
    @BlackbirdColumn var indvId: Int

    @BlackbirdColumn var emailId: Int
    @BlackbirdColumn var emailType: String?
    @BlackbirdColumn var emailTypeId: Int?
    @BlackbirdColumn var preferred: Bool?
    @BlackbirdColumn var email: String?
    @BlackbirdColumn var listed: Bool?
    
    init(from apiResponse: IndividualContactResponse.Email, for indvId: Int) {
        self.indvId = indvId
        self.emailId = apiResponse.EmailId
        self.emailType = apiResponse.EmailType
        self.emailTypeId = apiResponse.EmailTypeId
        self.preferred = apiResponse.Preferred
        self.email = apiResponse.Email
        self.listed = apiResponse.Listed
    }
}
