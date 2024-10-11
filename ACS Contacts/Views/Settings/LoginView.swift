//
//  LoginView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode
    @State private var showLogoutSuccessful = false
    
    @ObservedObject private var userManager = UserManager.shared
    
    @AppStorage("loginEmail") var email = ""
    @AppStorage("loginPassword") var password = ""
    @AppStorage("siteNumber") var siteNumber: String = ""
    
    @AppStorage("isAppReviewTesting") var isTesting: Bool = false
    
    @State private var alertTitle: String = "Default error title"
    @State private var alertMessage: String = "Default error message"
    @State private var showAlert: Bool = false
    
    @State private var showProgressView: Bool = false
    
    var requiredFieldsEmpty: Bool {
        return email.isEmpty ||
        password.isEmpty
    }
    
    var body: some View {
        List {
            Section("ACS/Realm Login Info") {
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
            }
            
            Section {
                Button("Login") { login() }
                    .disabled(requiredFieldsEmpty)
            }
            
            if (userManager.currentUser?.loggedIn ?? true) || email == AppStoreTesting.testString {
                HStack {
                    Image(systemName: "arrow.left.circle")
                    Button("Logout", role: .destructive) {
                        logout()
                    }
                }
                .alert(isPresented: $showLogoutSuccessful) {
                    Alert(
                        title: Text("Logout Successful!"),
                        message: Text("Please login to continue using this app")
                    )
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage)
            )
        }
        .overlay {
            if showProgressView {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // 1
                    .background(Color.gray)
                    .opacity(0.5)
            }
        }
        .navigationBarTitle("Login", displayMode: .inline)
    }
    
    fileprivate func login() {
        Task {
            if Config.appConfiguration != .AppStore {
                if email.lowercased() == AppStoreTesting.testString.lowercased() {
                    isTesting = true
                    showProgressView = true
                    await contactsFromJson()
                    showProgressView = false
                    mode.wrappedValue.dismiss()
                }
            }
            
            showProgressView = true
            let authTokens = await ACSService().login(email, password)
            switch authTokens {
            case .success(let profile):
                // Save the profile to UserManager or whatever is needed
                UserManager.shared.updateProfile(from: profile, email: email, password: password)
                siteNumber = profile.SiteNumber.description
                mode.wrappedValue.dismiss()
            case .failure(let error):
                print(error)
                alertTitle = "Login Failed"
                alertMessage = error.customMessage
                showAlert = true
            }
            showProgressView = false
        }
    }

    private func logout() {
        UserManager.shared.logout()
        email = ""
        password = ""
        alertTitle = "Logout Successful!"
        alertMessage = "Please login to continue using this app"
        showAlert = true
    }
}
