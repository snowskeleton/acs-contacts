//
//  HTTPQueryTypes.swift
//  ACS Contacts
//
//  Created by snow on 9/29/23.
//

import Foundation


protocol HTTPQuery: Codable {
    /// The format of the response to expect from the GraphQL request
    associatedtype Response: Decodable
    
    /**
     Decode a `Data` object from the GraphQL endpoint into our expected `Response` type.
     
     - Parameter data: `Data` - bytes from the network
     */
    static func decodeResponse(_ data: Data) throws -> Response
}

extension HTTPQuery {
    static func decodeResponse(_ data: Data) throws -> Response {
        try JSONDecoder().decode(Response.self, from: data)
    }
}

struct FindByEmailResponse: Codable {
    let FullName: String
    let UserName: String
    let SiteNumber: String
    let SiteName: String
}

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

struct ContactList: Codable {
    let Page: [Contact]
    let PageCount: Int
    let PageIndex: Int
    let PageSize: Int
    
    struct Contact: Codable {
        let IndvId: Int
        let FamId: Int
        let FamilyPosition: String?
        let Title: String?
        let FirstName: String
        let LastName: String
        let MiddleName: String?
        let GoesByName: String?
        let Suffix: String?
        let PictureUrl: String?
        let StatusSelected: String?
    }
}

//struct Profile: HTTPQuery {
//    var firstName: String
//    var lastName: String
//    var displayName: String
//    
//    struct Response: Codable {
//        let ccpaProtectData: Bool
//        let dataOptIn: Bool
//        let displayName: String
//        let emailOptIn: Bool
//        let emailVerified: Bool
//        let firstName: String
//        let lastName: String
//        let targetedAnalyticsOptOut: Bool
//    }
//}
