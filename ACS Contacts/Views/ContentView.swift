//
//  ContentView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var loggedIn = false
    
    @ObservedObject var userManager = UserManager.shared

    var body: some View {
        TabView {
            Tab("Contacts", systemImage: "person.crop.circle") {
                AllContactsView()
            }
            Tab("Settings", systemImage: "gear.circle") {
                SettingsView()
            }
        }
        .onAppear {
            loggedIn = !(userManager.currentUser?.loggedIn ?? true)
        }
        .onReceive(userManager.$currentUser) { newValue in
            loggedIn = !(newValue?.loggedIn ?? true)
        }
        .sheet(isPresented: $loggedIn) {
            NavigationStack {
                LoginView()
            }
        }
        .environment(\.horizontalSizeClass, .compact)
    }
}
