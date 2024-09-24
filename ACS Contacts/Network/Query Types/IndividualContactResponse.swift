//
//  IndividualContactResponse.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//


import Foundation

struct IndividualContactResponse: Codable {
    let IndvId: Int
    let PrimFamily: Int
    let LastName: String?
    let FirstName: String?
    let MiddleName: String?
    let GoesbyName: String?
    let Suffix: String?
    let Title: String?
    let FullName: String?
    let FriendlyName: String?
    let PictureUrl: String?
    let FamilyPictureUrl: String?
    let DateOfBirth: String?
    let MemberStatus: String?
    let FamilyPosition: String?
    let UserIsLeaderOf: Bool?
    let IsCRPending: Bool?
    let Addresses: [Address]
    let Emails: [Email]
    let Phones: [Phone]
    let FamilyMembers: [FamilyMember]
    let OtherRelationships: [Relationship]
    
    struct Address: Codable {
        let AddrId: Int
        let AddrTypeId: Int?
        let AddrType: String?
        let FamilyAddress: Bool?
        let ActiveAddress: Bool?
        let MailAddress: Bool?
        let StatementAddress: Bool?
        let Country: String?
        let Company: String?
        let Address: String?
        let Address2: String?
        let City: String?
        let State: String?
        let Zipcode: String?
        let CityStateZip: String?
        let Latitude: String?
        let Longitude: String?
        let Delete: Bool?
    }
    
    struct Email: Codable {
        let EmailId: Int
        let EmailType: String?
        let EmailTypeId: Int?
        let Preferred: Bool?
        let Email: String?
        let Listed: Bool?
        let Delete: Bool?
    }
    
    struct Phone: Codable {
        let PhoneId: Int
        let Preferred: Bool?
        let PhoneTypeId: Int?
        let PhoneType: String?
        let FamilyPhone: Bool?
        let PhoneNumber: String?
        let Extension: String?
        let Listed: Bool?
        let AddrPhone: Bool?
        let PhoneRef: Int?
        let Delete: Bool?
    }
    
    struct FamilyMember: Codable {
        //undefined
    }
    
    struct Relationship: Codable {
        //undefined
    }
}
