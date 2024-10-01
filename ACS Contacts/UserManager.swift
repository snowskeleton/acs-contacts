//
//  UserManager.swift
//  ACS Contacts
//
//  Created by snow on 8/25/24.
//

import Foundation
import SwiftData

class UserManager: ObservableObject {
    static let shared = UserManager()
     let userDefaultsKey = "user"

    @Published private(set) var currentUser: User?

    private init() {
        loadUser()
    }

    func loadUser() {
        guard
            let userData = UserDefaults.standard.data(forKey: self.userDefaultsKey),
            let user = try? JSONDecoder().decode(User.self, from: userData)
        else {
            self.currentUser = User()
            return
        }
        self.currentUser = user
    }

    func saveUser() {
        if let user = UserManager.shared.currentUser {
            UserManager.shared.saveUser(user)
        }
    }
    
    func saveUser(_ user: User) {
        guard let userData = try? JSONEncoder().encode(user) else { return }
        UserDefaults.standard.set(userData, forKey: self.userDefaultsKey)
        self.currentUser = user
    }
    
    func updateProfile(from profile: SiteProfile.Response, email: String, password: String) {
        if let user = UserManager.shared.currentUser {
            user.fullName = "\(profile.FirstName) \(profile.LastName)"
            user.userName = profile.UserName
            user.siteNumber = String(profile.SiteNumber)
            user.email = email
            user.password = password
            saveUser(user)
            loadUser()
        }
    }
    
    func logout() {
        if let user = UserManager.shared.currentUser {
            user.email = nil
            user.password = nil
            user.fullName = nil
            user.userName = nil
            user.siteName = nil
            user.siteNumber = nil
            UserManager.shared.saveUser(user)
            UserManager.shared.loadUser()
            Analytics.track(.logout)
        }
    }
}

class User: Codable {
    var fullName: String?
    var userName: String?
    var siteNumber: String?
    var siteName: String?

    var email: String?
    var password: String?

    init() { }
    init(from response: FindByEmailResponse) {
        self.fullName = response.FullName
        self.userName = response.UserName
        self.siteNumber = response.SiteNumber
        self.siteName = response.SiteName
    }
    
    var loggedIn: Bool {
        return self.password != nil
    }
}
