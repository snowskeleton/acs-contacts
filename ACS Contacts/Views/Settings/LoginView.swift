//
//  LoginView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode
    @State private var loggedIn = false
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
            Section {
                TextField("Email", text: $email)
                SecureField("Password", text: $password)
            } header: {
                Text("Email and password")
            }
            
            Section {
                Button("Login") { login() }
                    .disabled(requiredFieldsEmpty)
            }
            
            if !email.isEmpty && !password.isEmpty {
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
            
            if email == AppStoreTesting.testString {
                Button("Create fake data") {
                    Task {
                        isTesting = true
                        showProgressView = true
                        await contactsFromJson()
                        alertTitle = "Fake data created"
                        alertMessage = ""
                        showAlert = true
                        showProgressView = false
                        
                    }
                }
            }
            
            //            Section {
            //                if email.lowercased() == AppStoreTesting.testString {
            //                    NavigationLink {
            //                        CreateFakeEventView()
            //                    } label: {
            //                        Text("Create data for testing")
            //                    }
            //                }
            //            }
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
