//
//  DatabaseManager.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

import Foundation
import SwiftData

public class DatabaseManager {
    
    public static let sharedContainer: ModelContainer = {
        let schema = Schema([
            ContextItem.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
