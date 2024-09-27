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
    request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 12, to: Date())
    do {
        try BGTaskScheduler.shared.submit(request)
        print("Background Task Scheduled!")
    } catch {
        print("Could not schedule app refresh: \(error)")
    }
}
