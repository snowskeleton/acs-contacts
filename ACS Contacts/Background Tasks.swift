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
//    switch await fetchContacts(onProgressUpdate: { _, _, contacts in
//        Task.detached {
//            for apiContact in contacts {
//                let actor = SwiftDataActor(modelContainer: SwiftDataManager.shared.container)
//                await actor.createContact(apiContact)
//            }
//        }
//    }) {
//    case .success(let contacts):
//        try? SwiftDataManager.shared.container.mainContext.save()
//        print("saving \(contacts.count) contacts")
//        UserDefaults.standard.set(true, forKey: "completedInitialDownload")
//    case .failure(let error):
//        print("Failed to save contacts: \(error)")
//    }
}
