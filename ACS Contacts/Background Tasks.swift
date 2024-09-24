//
//  Background Tasks.swift
//  ACS Contacts
//
//  Created by snow on 9/24/24.
//

import Foundation
import BackgroundTasks

func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "contactListDownload")
    do {
        try BGTaskScheduler.shared.submit(request)
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
}

@MainActor
func fetchContactsInBackground() async {
    switch await fetchContacts(onProgressUpdate: { _, _ in}) {
    case .success(let contacts):
        print("saving \(contacts.count) contacts")
        for apiContact in contacts {
            let newContact = Contact.createOrUpdate(from: apiContact)
            SwiftDataManager.shared.container.mainContext.insert(newContact)
        }
        
        do {
            try SwiftDataManager.shared.container.mainContext.save()
        } catch {
            print("Failed to save contacts: \(error)")
        }

    case .failure(let error):
        print("Failed to save contacts: \(error)")
    }
}
