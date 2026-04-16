//
//  HealthProvider.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

import Foundation
#if canImport(HealthKit)
import HealthKit

public actor HealthProvider: ContextProvider {
    public let providerName = "HealthKit"
    private let healthStore = HKHealthStore()
    
    public init() {}
    
    // MARK: - Authorization
    public func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw NSError(domain: "ContextOS", code: 1, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device."])
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        let typesToRead: Set = [sleepType]
        
        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
    }
    
    // MARK: - Data Retrieval (Protocol Conformance)
    public func fetchCurrentState() async throws -> Double {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return 0.0
        }
        
        // Define the timeframe: Last 24 hours
        let endDate = Date()
        let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // Sort to get the most recent sleep segments first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
                
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let sleepSamples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                // Filter for actual time asleep
                let asleepSamples = sleepSamples.filter {
                    $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                    $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                    $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                    $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
                }
                
                // Calculate total duration in hours
                let totalSleepSeconds = asleepSamples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                let totalSleepHours = totalSleepSeconds / 3600.0
                
                continuation.resume(returning: totalSleepHours)
            }
            healthStore.execute(query)
        }
    }
}
#endif
