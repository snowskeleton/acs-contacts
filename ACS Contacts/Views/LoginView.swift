//
//  LoginView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.presentationMode) var mode
    
    @AppStorage("loginEmail") var email = ""
    @AppStorage("loginPassword") var password = ""
    
    @State private var alertErrorTitle: String = "Default error title"
    @State private var alertErrorMessage: String = "Default error message"
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
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(alertErrorTitle),
                            message: Text(alertErrorMessage)
                        )
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
                mode.wrappedValue.dismiss()
            case .failure(let error):
                print(error)
                alertErrorTitle = "Login Failed"
                alertErrorMessage = error.customMessage
                showAlert = true
            }
            showProgressView = false
        }
    }
}
