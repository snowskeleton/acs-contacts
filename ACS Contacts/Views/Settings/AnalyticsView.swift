//
//  AnalyticsView.swift
//  OSTRich
//
//  Created by snow on 8/29/24.
//

import SwiftUI

struct AnalyticsView: View {
    @AppStorage("isAnalyticsDisabled") var disableAnalytics = false
    @AppStorage("optInTrackingIdentifier") var optInTrackingIdentifier = ""
    @AppStorage("optInTrackingIdentifierExpiry") var optInTrackingIdentifierExpiryTimestamp: Double = 0
    
    var optInTrackingIdentifierExpiry: Date {
        get {
            Date(timeIntervalSince1970: optInTrackingIdentifierExpiryTimestamp)
        }
        set {
            optInTrackingIdentifierExpiryTimestamp = newValue.timeIntervalSince1970
        }
    }
    
    var body: some View {
        List {
            Section {
                Toggle("Enable Analytics", isOn: Binding(
                    get: { !disableAnalytics },
                    set: {
                        Analytics.track(!$0 ? .analyticsDisabled : .analyticsEnabled)
                        disableAnalytics  = !$0
                        Analytics.track(!$0 ? .analyticsDisabled : .analyticsEnabled)
                    }
                ))
            } header: {
                Text("Analytics")
            } footer: {
                Text("\(disableAnalytics ? "No" : "Only") app usage is tracked. No personally identifible information is saved. No information is sold to or used by third parties.")
            }
            
            if !disableAnalytics {
                Section {
                    TextField("Tracking ID", text: $optInTrackingIdentifier)
                        .onChange(of: optInTrackingIdentifier) {
                            if let expiryDate = Calendar.current.date(byAdding: .day, value: 2, to: Date()) {
                                optInTrackingIdentifierExpiryTimestamp = expiryDate.timeIntervalSince1970
                            }
                        }
                } header: {
                    Text("Opt-In Tracking")
                } footer: {
                    Text("Only enter an identifier in here if provided one by the app developer to help troubleshoot a specific issue. This identifier will uniquely identify you and your app's usage. Analytics must be enabled for this to work. This identifier is cleared automatically after 2 days. No info is sold to or used by third parties.")
                }
            }
        }
        .onAppear {
            Analytics.track(.openedAnalyticsView)
        }
        .navigationTitle("Analytics")
    }
}
