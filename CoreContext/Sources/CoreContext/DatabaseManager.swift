//
//  DatabaseManager.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

import Foundation
import SwiftData

public actor DatabaseManager {
    public static let shared = DatabaseManager()
    public let container: ModelContainer
    
    private init() {
        let schema = Schema([
            ContextItem.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
