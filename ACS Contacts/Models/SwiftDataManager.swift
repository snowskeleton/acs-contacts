//
//  SwiftDataManager.swift
//  OSTRich
//
//  Created by snow on 8/24/24.
//

import Foundation
import SwiftData

public class SwiftDataManager {
    
    public static let shared = SwiftDataManager()
    
    public let container: ModelContainer = {
        
        let schema = Schema([
            Address.self,
            Contact.self,
            Email.self,
            Phone.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            do {
                NSLog("Failed to load current schema and config. Cleraing and trying again")
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()
    
    
    }
