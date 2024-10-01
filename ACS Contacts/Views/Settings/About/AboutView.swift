//
//  AboutView.swift
//  OSTRich
//
//  Created by snow on 9/2/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Text(Bundle.main.appName)
                .font(.largeTitle)
                .bold()
            Text("Version: \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))")
            Text("By Isaac Lyons")
            Text(Bundle.main.copyright)
            List {
                NavigationLink {
                    MarkdownView(markdownFile: "PRIVACY_POLICY.md", title: "Privacy Policy")
                } label: {
                    HStack {
                        Image(systemName: "checkmark.shield")
                        Text("Privacy Policy")
                    }
                }
                NavigationLink {
                    LicenseView()
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Licenses & Libraries")
                    }
                }
                HStack {
                    Image(systemName: "scroll")
                    Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                        Text("Terms of Use")
                    }
                }
            }
        }
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}
