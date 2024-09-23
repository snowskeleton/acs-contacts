//
//  ContentView.swift
//  ACS Contacts
//
//  Created by snow on 9/23/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    var body: some View {
        TabView {
            Tab("Contacts", systemImage: "person.crop.circle") {
                AllContactsView()
            }
            Tab("Settings", systemImage: "gear.circle") {
                SettingsView()
            }
        }
        .environment(\.horizontalSizeClass, .compact)
    }
}
