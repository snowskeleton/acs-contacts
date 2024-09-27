//
//  Phone.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import Blackbird

struct Phone: BlackbirdModel, Identifiable {
    static var primaryKey: [BlackbirdColumnKeyPath] = [ \.$phoneId ]
    
    //Contact
    @BlackbirdColumn var indvId: Int

    @BlackbirdColumn var phoneId: Int
    @BlackbirdColumn var phoneType: String?
    @BlackbirdColumn var phoneTypeId: Int?
    @BlackbirdColumn var preferred: Bool?
    @BlackbirdColumn var phoneNumber: String?
    @BlackbirdColumn var listed: Bool?
    @BlackbirdColumn var familyPhone: Bool?
    @BlackbirdColumn var phoneExtension: String?
    @BlackbirdColumn var addrPhone: Bool?
    @BlackbirdColumn var phoneRef: String?
    @BlackbirdColumn var searchablePhoneNumber: String

    init(from apiResponse: IndividualContactResponse.Phone, for indvId: Int) {
        self.indvId = indvId
        self.phoneId = apiResponse.PhoneId
        self.phoneType = apiResponse.PhoneType
        self.phoneTypeId = apiResponse.PhoneTypeId
        self.preferred = apiResponse.Preferred
        self.phoneNumber = apiResponse.PhoneNumber
        self.listed = apiResponse.Listed
        self.familyPhone = apiResponse.FamilyPhone
        self.phoneExtension = apiResponse.Extension
        self.addrPhone = apiResponse.AddrPhone
        self.phoneRef = apiResponse.PhoneRef?.description
        self.searchablePhoneNumber = (apiResponse.PhoneNumber ?? "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}
