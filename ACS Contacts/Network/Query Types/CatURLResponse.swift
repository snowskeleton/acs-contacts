//
//  CatURLResponse.swift
//  ACS Contacts
//
//  Created by snow on 9/30/24.
//

import Foundation

struct CatURLResponse: Codable {
    let url: String
    
    private enum CodingKeys: String, CodingKey {
        case url
    }
}
