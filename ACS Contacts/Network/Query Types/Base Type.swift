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
