//
//  Email.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import SwiftData

@Model
class Email: Identifiable {
    @Attribute(.unique)
    var emailId: Int
    var emailType: String?
    var emailTypeId: Int?
    var preferred: Bool?
    var email: String?
    var listed: Bool?
    
    init(
        emailId: Int,
        emailType: String?,
        emailTypeId: Int?,
        preferred: Bool?,
        email: String?,
        listed: Bool?
    ) {
        self.emailId = emailId
        self.emailType = emailType
        self.emailTypeId = emailTypeId
        self.preferred = preferred
        self.email = email
        self.listed = listed
    }
    
    init(from apiResponse: IndividualContactResponse.Email) {
        self.emailId = apiResponse.EmailId
        self.emailType = apiResponse.EmailType
        self.emailTypeId = apiResponse.EmailTypeId
        self.preferred = apiResponse.Preferred
        self.email = apiResponse.Email
        self.listed = apiResponse.Listed
    }
    
    func update(with apiResponse: IndividualContactResponse.Email) {
        self.emailId = apiResponse.EmailId
        self.emailType = apiResponse.EmailType
        self.emailTypeId = apiResponse.EmailTypeId
        self.preferred = apiResponse.Preferred
        self.email = apiResponse.Email
        self.listed = apiResponse.Listed
    }

    
    @MainActor static func createOrUpdate(
        from apiEmail: IndividualContactResponse.Email
    ) -> Email {
        let fetchDescriptor = FetchDescriptor<Email>(
            predicate: #Predicate<Email> { $0.emailId == apiEmail.EmailId }
        )
        let context = SwiftDataManager.shared.container.mainContext
        let emails = try? context.fetch(fetchDescriptor)
        
        if let finalEmail = (emails ?? []).first {
            finalEmail.update(with: apiEmail)
            return finalEmail
        } else {
            return .init(from: apiEmail)
        }
    }
}
