//
//  HTTP Network Manager.swift
//  ACS Contacts
//
//  Created by snow on 9/4/23.
//

import Foundation
import SwiftUI

enum ACSEndpoint {
    case findByEmail(email: String, password: String)
    case login(siteNumber: String, username: String, password: String)
    case getContacts(siteNumber: String, pageIndex: Int)
    case getIndividualContact(siteNumber: String, indvId: String)
}

extension ACSEndpoint: Endpoint {
    var path: String {
        switch self {
        case .findByEmail:
            return "/api_accessacs_mobile/v2/accounts/findbyemail"
        case .login(let siteNumber, _, _):
            return "/api_accessacs_mobile/v2/\(siteNumber)/account"
        case .getContacts(let siteNumber, _):
            return "/api_accessacs_mobile/v2/\(siteNumber)/individuals/find"
        case .getIndividualContact(let siteNumber, let indvId):
            return "/api_accessacs_mobile/v2/\(siteNumber)/individuals/\(indvId)"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .getContacts(_, let pageIndex):
            var pageSize = UserDefaults.standard.integer(forKey: "fetchContactsPageSize")
            if pageSize == 0 { pageSize = 50 }
            return [
                URLQueryItem(name: "q", value: "%"), // Use %25 for the percent character
                URLQueryItem(name: "pageIndex", value: "\(pageIndex)"),
                URLQueryItem(name: "pageSize", value: "\(pageSize)"),

            ]
        default:
            return nil
        }
    }

    var host: String {
        return "secure.accessacs.com"
    }
    
    var method: RequestMethod {
        switch self {
        case .findByEmail:
            return .put
        case .getContacts:
            return .get
        default:
            return .get
        }
    }
    
    var header: [String: String]? {
        switch self {
        case .findByEmail:
            return [
                "X-NewRelic-ID": "UAEHWFBACgMCVVBSBw==",
                "AcsApplicationID": "E17686B7-C9B8-F34A-10E5-000D98A7CEE8",
                "Content-Type": "application/json"
            ]
        case .login(_, let username, let password):
            let base64Credentials = "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString() ?? ""
            return [
                "Authorization": "Basic \(base64Credentials)",
                "Content-Type": "application/json"
            ]
        default:
            guard let username = UserManager.shared.currentUser?.userName else {
                return nil
            }
            guard let password = UserManager.shared.currentUser?.password else {
                return nil
            }
            let base64Credentials = "\(username):\(password)"
                .data(using: .utf8)?
                .base64EncodedString() ?? ""
            return [
                "Authorization": "Basic \(base64Credentials)",
                "Content-Type": "application/json"
            ]
        }
    }
    
    var body: [String: Any]? {
        switch self {
        case .findByEmail(let email, let password):
            return [
                "email": email,
                "password": password
            ]
            
        default:
            return nil
        }
    }
}
protocol ACSServiceable {
    func login(_ email: String, _ password: String) async -> Result<SiteProfile.Response, RequestError>
}

struct ACSService: HTTPClient, ACSServiceable {
    func getIndividualContact(siteNumber: String, indvId: String) async -> Result<IndividualContactResponse, RequestError> {
        return await sendRequest(
            endpoint: ACSEndpoint.getIndividualContact(siteNumber: siteNumber, indvId: indvId),
            responseModel: IndividualContactResponse.self
        )
    }

    func getContacts(siteNumber: String, pageIndex: Int = 0) async -> Result<ContactList, RequestError> {
        return await sendRequest(endpoint: ACSEndpoint.getContacts(siteNumber: siteNumber, pageIndex: pageIndex), responseModel: ContactList.self)
    }
    
    func login(_ email: String, _ password: String) async -> Result<SiteProfile.Response, RequestError> {
        Analytics.track(.login)
        
        let findByEmailResult = await sendRequest(endpoint: ACSEndpoint.findByEmail(email: email, password: password), responseModel: [FindByEmailResponse].self)
        
        switch findByEmailResult {
        case .success(let findResponse):
            guard let userInfo = findResponse.first else {
                return .failure(RequestError.noSiteNumber)
            }
            
            let siteNumber = userInfo.SiteNumber
            let userName = userInfo.UserName
            
            let loginResult = await sendRequest(endpoint: ACSEndpoint.login(siteNumber: siteNumber, username: userName, password: password), responseModel: SiteProfile.Response.self)
            
            return loginResult
            
        case .failure(let error):
            return .failure(error)
        }
    }
}
