//
//  FindByEmailResponse.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//


import Foundation

struct FindByEmailResponse: Codable {
    let FullName: String
    let UserName: String
    let SiteNumber: String
    let SiteName: String
}