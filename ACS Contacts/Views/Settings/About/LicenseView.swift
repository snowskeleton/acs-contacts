//
//  LicenseView.swift
//  ACS Contacts
//
//  Created by snow on 9/2/24.
//

import SwiftUI

struct LicenseView: View {
    var body: some View {
        List {
            Section("Apache 2.0") {
                NavigationLink {
                    MarkdownView(markdownFile: "LICENSE", title: "License")
                } label: {
                    Text("ACS Contacts")
                }

            }
            
            Section("MIT") {
                Link(destination: URL(string: "https://github.com/gonzalezreal/swift-markdown-ui/blob/main/LICENSE")!) {
                    Text("MarkdownUI")
                }
            }
            
            Section("AGPL") {
                Link(destination: URL(string: "https://github.com/aptabase/aptabase/blob/main/LICENSE")!) {
                    Text("Aptabase")
                }
            }
        }
        .navigationTitle("Licenses")
    }
}

#Preview {
    LicenseView()
}
