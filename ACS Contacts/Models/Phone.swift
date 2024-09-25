//
//  Phone.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import SwiftData

@Model
class Phone: Identifiable {
    @Attribute(.unique)
    var phoneId: Int
    var phoneType: String?
    var phoneTypeId: Int?
    var preferred: Bool?
    var phoneNumber: String?
    var listed: Bool?
    var familyPhone: Bool?
    var phoneExtension: String?
    var addrPhone: Bool?
    var phoneRef: String?
    
    var searchablePhoneNumber: String {
        return (phoneNumber ?? "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
    
    init(
        phoneId: Int,
        phoneType: String?,
        phoneTypeId: Int?,
        preferred: Bool?,
        phoneNumber: String?,
        listed: Bool?,
        familyPhone: Bool?,
        phoneExtension: String?,
        addrPhone: Bool?,
        phoneRef: String?
    ) {
        self.phoneId = phoneId
        self.phoneType = phoneType
        self.phoneTypeId = phoneTypeId
        self.preferred = preferred
        self.phoneNumber = phoneNumber
        self.listed = listed
        self.familyPhone = familyPhone
        self.phoneExtension = phoneExtension
        self.addrPhone = addrPhone
        self.phoneRef = phoneRef
    }
    
    init(from apiResponse: IndividualContactResponse.Phone) {
        self.phoneId = apiResponse.PhoneId
        self.phoneType = apiResponse.PhoneType
        self.phoneTypeId = apiResponse.PhoneTypeId
        self.preferred = apiResponse.Preferred
        self.phoneNumber = apiResponse.PhoneNumber
        self.listed = apiResponse.Listed
        self.familyPhone = familyPhone
        self.phoneExtension = phoneExtension
        self.addrPhone = addrPhone
        self.phoneRef = phoneRef
    }
    
    func update(with apiResponse: IndividualContactResponse.Phone) {
        self.phoneId = apiResponse.PhoneId
        self.phoneType = apiResponse.PhoneType
        self.phoneTypeId = apiResponse.PhoneTypeId
        self.preferred = apiResponse.Preferred
        self.phoneNumber = apiResponse.PhoneNumber
        self.listed = apiResponse.Listed
        self.familyPhone = familyPhone
        self.phoneExtension = phoneExtension
        self.addrPhone = addrPhone
        self.phoneRef = phoneRef
    }
    
    @MainActor static func createOrUpdate(
        from apiPhone: IndividualContactResponse.Phone
    ) -> Phone {
        let fetchDescriptor = FetchDescriptor<Phone>(
            predicate: #Predicate<Phone> { $0.phoneId == apiPhone.PhoneId }
        )
        let context = SwiftDataManager.shared.container.mainContext
        let phones = try? context.fetch(fetchDescriptor)
        
        if let finalPhone = (phones ?? []).first {
            finalPhone.update(with: apiPhone)
            return finalPhone
        } else {
            return .init(from: apiPhone)
        }
    }

}
