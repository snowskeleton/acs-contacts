//
//  SiteProfile.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//


import Foundation

struct SiteProfile {
    struct Response: Codable {
        let SiteNumber: Int
        let Email: String
        let UserName: String
        let FirstName: String
        let LastName: String
        let Phone: String
    }
}