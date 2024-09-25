//
//  Address.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import SwiftData

@Model
class Address: Identifiable {
    @Attribute(.unique)
    var addrId: Int
    var addrTypeId: Int?
    var addrType: String?
    var familyAddress: Bool?
    var activeAddress: Bool?
    var mailAddress: Bool?
    var statementAddress: Bool?
    var country: String?
    var addressLine1: String?
    var addressLine2: String?
    var city: String?
    var state: String?
    var zipcode: String?
    var cityStateZip: String?
    
    var addressString: String {
        var starterString = ""
        if let line1 = addressLine1, !line1.isEmpty {
            starterString += "\(line1)"
        }
        
        if let line2 = addressLine2, !line2.isEmpty {
            starterString += "\n\(line2)"
        }
        
        if let cityStateZip = cityStateZip, !cityStateZip.isEmpty {
            starterString += "\n\(cityStateZip)"
        }
        
        if let country = country, !country.isEmpty {
            starterString += "\n\(country)"
        }
        
        return starterString
    }

    
    init(
        addrId: Int,
        addrTypeId: Int?,
        addrType: String?,
        familyAddress: Bool?,
        activeAddress: Bool?,
        mailAddress: Bool?,
        statementAddress: Bool?,
        country: String?,
        addressLine1: String?,
        addressLine2: String? = nil,
        city: String?,
        state: String?,
        zipcode: String?,
        cityStateZip: String?
    ) {
        self.addrId = addrId
        self.addrTypeId = addrTypeId
        self.addrType = addrType
        self.familyAddress = familyAddress
        self.activeAddress = activeAddress
        self.mailAddress = mailAddress
        self.statementAddress = statementAddress
        self.country = country
        self.addressLine1 = addressLine1
        self.addressLine2 = addressLine2
        self.city = city
        self.state = state
        self.zipcode = zipcode
        self.cityStateZip = cityStateZip
    }
    
    init(from apiResponse: IndividualContactResponse.Address) {
        self.addrId = apiResponse.AddrId
        self.addrTypeId = apiResponse.AddrTypeId
        self.addrType = apiResponse.AddrType
        self.familyAddress = apiResponse.FamilyAddress
        self.activeAddress = apiResponse.ActiveAddress
        self.mailAddress = apiResponse.MailAddress
        self.statementAddress = apiResponse.StatementAddress
        self.country = apiResponse.Country
        self.addressLine1 = apiResponse.Address
        self.addressLine2 = apiResponse.Address2
        self.city = apiResponse.City
        self.state = apiResponse.State
        self.zipcode = apiResponse.Zipcode
        self.cityStateZip = apiResponse.CityStateZip
    }
    
    func update(with apiResponse: IndividualContactResponse.Address) {
        self.addrId = apiResponse.AddrId
        self.addrTypeId = apiResponse.AddrTypeId
        self.addrType = apiResponse.AddrType
        self.familyAddress = apiResponse.FamilyAddress
        self.activeAddress = apiResponse.ActiveAddress
        self.mailAddress = apiResponse.MailAddress
        self.statementAddress = apiResponse.StatementAddress
        self.country = apiResponse.Country
        self.addressLine1 = apiResponse.Address
        self.addressLine2 = apiResponse.Address2
        self.city = apiResponse.City
        self.state = apiResponse.State
        self.zipcode = apiResponse.Zipcode
        self.cityStateZip = apiResponse.CityStateZip
    }
}
