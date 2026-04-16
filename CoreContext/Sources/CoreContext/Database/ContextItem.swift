//
//  ContextItem.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

import Foundation
import SwiftData

@Model
public final class ContextItem {
    // Core Identity
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    
    // Display Data
    public var title: String = ""
    public var category: String = ""
    
    // Associated Data (Optional)
    public var numericValue: Double?
    public var textContent: String?
    
    public init(title: String, category: String, numericValue: Double? = nil, textContent: String? = nil) {
        self.id = UUID()
        self.timestamp = Date()
        self.title = title
        self.category = category
        self.numericValue = numericValue
        self.textContent = textContent
    }
}
