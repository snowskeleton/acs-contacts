//
//  Background Tasks.swift
//  ACS Contacts
//
//  Created by snow on 9/24/24.
//

import Foundation
import BackgroundTasks
import Blackbird
import SwiftUI

func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "contactListDownload")
        request.earliestBeginDate = Calendar.current.date(byAdding: .second, value: 5, to: Date())
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task Scheduled!")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
}

@MainActor
func fetchContactsInBackground() async {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let databasePath = documentsDirectory.appendingPathComponent("contacts.sqlite").path
    let db = try! Blackbird.Database(path: databasePath)

    switch await fetchContacts(onProgressUpdate: { _, _, _ in }) {
    case .success(let contacts):
        await Contact.bulkInit(db, contacts)
        print("saving \(contacts.count) contacts")
        UserDefaults.standard.set(true, forKey: "completedInitialDownload")
    case .failure(let error):
        print("Failed to save contacts: \(error)")
    }
}
