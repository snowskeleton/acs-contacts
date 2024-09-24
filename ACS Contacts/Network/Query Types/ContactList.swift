//
//  ContactList.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//


import Foundation

struct ContactList: Codable {
    let Page: [Contact]
    let PageCount: Int
    let PageIndex: Int
    let PageSize: Int
    
    struct Contact: Codable {
        let IndvId: Int
        let FamId: Int?
        let PrimFamily: Int?
        let FamilyPosition: String?
        let Title: String?
        let FirstName: String?
        let LastName: String?
        let MiddleName: String?
        let GoesByName: String?
        let Suffix: String?
        let PictureUrl: String?
        let StatusSelected: String?
    }
}
