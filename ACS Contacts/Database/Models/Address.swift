//
//  Address.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import Foundation
import Blackbird

struct Address: BlackbirdModel, Identifiable {
    static var primaryKey: [BlackbirdColumnKeyPath] = [ \.$addrId ]
    
    //Contact
    @BlackbirdColumn var indvId: Int
    
    @BlackbirdColumn var addrId: Int
    @BlackbirdColumn var addrTypeId: Int?
    @BlackbirdColumn var addrType: String?
    @BlackbirdColumn var familyAddress: Bool?
    @BlackbirdColumn var activeAddress: Bool?
    @BlackbirdColumn var mailAddress: Bool?
    @BlackbirdColumn var statementAddress: Bool?
    @BlackbirdColumn var country: String?
    @BlackbirdColumn var addressLine1: String?
    @BlackbirdColumn var addressLine2: String?
    @BlackbirdColumn var city: String?
    @BlackbirdColumn var state: String?
    @BlackbirdColumn var zipcode: String?
    @BlackbirdColumn var cityStateZip: String?
    
    var addressString: String {
        var addressPieces: [String] = []
        
        if let addressLine1, !addressLine1.isEmpty {
            addressPieces.append(addressLine1)
        }
        
        if let addressLine2, !addressLine2.isEmpty {
            addressPieces.append(addressLine2)
        }
        
        if let cityStateZip, !cityStateZip.isEmpty {
            addressPieces.append(cityStateZip)
        }
        
        if let country, !country.isEmpty {
            addressPieces.append(country)
        }
        return addressPieces.joined(separator: "\n")
    }

    init(from apiResponse: IndividualContactResponse.Address, for indvId: Int) {
        self.indvId = indvId
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
