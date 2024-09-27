//
//  DatabaseManager.swift
//  ACS Contacts
//
//  Created by snow on 9/27/24.
//


import SwiftUI
import Blackbird

class DatabaseManager: ObservableObject {
    static let shared = DatabaseManager()
    
    @Published var database: Blackbird.Database?
    private var databasePath: String
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        databasePath = documentsDirectory.appendingPathComponent("contacts.sqlite").path
        database = try! Blackbird.Database(path: databasePath)
    }
}
