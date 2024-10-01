//
//  Catwork Manager.swift
//  ACS Contacts
//
//  Created by snow on 9/30/24.
//

import Foundation
import SwiftUI

enum CatEndpoint {
    case getCatURL
}

extension CatEndpoint: Endpoint {
    var path: String {
        switch self {
        case .getCatURL:
            return "/v1/images/search"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var host: String {
        return "api.thecatapi.com"
    }
    
    var method: RequestMethod {
        return .get
    }
    
    var header: [String: String]? {
        return [
            "x-api-key": CatAPI.key
        ]
    }
    
    var body: [String: Any]? {
        return nil
    }
}
protocol CatServiceable {
    func getCatURL() async -> Result<[CatURLResponse], RequestError>
}

struct CatService: HTTPClient, CatServiceable {
    func getCatURL() async -> Result<[CatURLResponse], RequestError> {
        return await sendRequest(endpoint: CatEndpoint.getCatURL, responseModel: [CatURLResponse].self)
    }
}
