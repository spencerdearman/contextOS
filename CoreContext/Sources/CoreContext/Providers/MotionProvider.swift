//
//  MotionProvider.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

import Foundation
#if canImport(CoreMotion)
import CoreMotion

public actor MotionProvider: ContextProvider {
    public let providerName = "CoreMotion"
    private let activityManager = CMMotionActivityManager()
    
    public init() {}
    
    // MARK: - Authorization
    public func requestAuthorization() async throws {
        guard CMMotionActivityManager.isActivityAvailable() else {
            throw NSError(domain: "ContextOS", code: 2, userInfo: [NSLocalizedDescriptionKey: "CoreMotion is not available on this device."])
        }
        
        // Trigger the system permission prompt by executing a zero-second historical query
        let now = Date()
        return try await withCheckedThrowingContinuation { continuation in
            activityManager.queryActivityStarting(from: now, to: now, to: .main) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }
    
    // MARK: - Data Retrieval (Protocol Conformance)
    public func fetchCurrentState() async throws -> Double {
        guard CMMotionActivityManager.isActivityAvailable() else { return 0.0 }
        
        let now = Date()
        // Query the last 5 minutes to determine the current sustained physical state
        let pastDate = now.addingTimeInterval(-300)
        
        return try await withCheckedThrowingContinuation { continuation in
            activityManager.queryActivityStarting(from: pastDate, to: now, to: .main) { activities, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let activities = activities, let mostRecent = activities.last else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                // Map the physical state to a numeric weight for the scoring engine
                if mostRecent.running {
                    continuation.resume(returning: 3.0)
                } else if mostRecent.cycling {
                    continuation.resume(returning: 2.5)
                } else if mostRecent.walking {
                    continuation.resume(returning: 2.0)
                } else if mostRecent.automotive {
                    continuation.resume(returning: 4.0)
                } else if mostRecent.stationary {
                    continuation.resume(returning: 1.0)
                } else {
                    continuation.resume(returning: 0.0) // Unknown state
                }
            }
        }
    }
}
#endif
