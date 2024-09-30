//
//  crud.swift
//  ACS Contacts
//
//  Created by snow on 9/27/24.
//


import SwiftUI
import SwiftData
import Blackbird

func fetchContacts(
    onProgressUpdate: @escaping (_ current: Int, _ total: Int, _ contacts: [ContactList.Contact]) -> Void
) async -> Result<[ContactList.Contact], RequestError> {
    guard let siteNumber = UserManager.shared.currentUser?.siteNumber else {
        return .failure(RequestError.custom("No site number"))
    }
    
    // tell calling function how many records we're aiming for
    var totalRecords: Int = 0
    let contactsResult = await ACSService().getContacts(
        siteNumber: siteNumber,
        pageIndex: 1,
        pageSize: 1
    )
    switch contactsResult {
    case .success(let contactsResponse):
        totalRecords = contactsResponse.PageCount
        onProgressUpdate(0, totalRecords, [])
    case .failure(let error):
        return .failure(error)
    }

    var pageSize = UserDefaults.standard.integer(forKey: "fetchContactsPageSize")
    if pageSize == 0 { pageSize = 500 }
    
    var pageIndex = 0
    var totalPages = Int.max
    var contacts: [ContactList.Contact] = []
    
    while pageIndex < totalPages {
        let contactsResult = await ACSService().getContacts(
            siteNumber: siteNumber,
            pageIndex: pageIndex,
            pageSize: pageSize
        )
        
        switch contactsResult {
        case .success(let contactsResponse):
            contacts.append(contentsOf: contactsResponse.Page)
            totalPages = contactsResponse.PageCount
            pageIndex += 1
            
            onProgressUpdate(contacts.count, totalRecords, contactsResponse.Page)
        case .failure(let error):
            return .failure(error)
        }
    }
    return .success(contacts)
}

func fetchContactsInBackground() async {
    if let db = DatabaseManager.shared.database {
        
        switch await fetchContacts(onProgressUpdate: { _, _, _ in }) {
        case .success(let contacts):
            await Contact.bulkInit(db, contacts)
            UserDefaults.standard.set(true, forKey: "completedInitialDownload")
        case .failure(let error):
            print("Failed to save contacts: \(error)")
        }
        
        let contacts = try! await Contact.read(from: db, matching: \.$isFullyUpdated == false, orderBy: .descending(\.$lastUpdated))
        if !contacts.isEmpty {
            await Contact.updateAll(db, contacts)
        } else {
            let contacts = try! await Contact.read(
                from: db,
                orderBy: .ascending(\.$lastUpdated),
                limit: 100
            )
            await Contact.updateAll(db, contacts)
        }
    }
    scheduleAppRefresh()
}
