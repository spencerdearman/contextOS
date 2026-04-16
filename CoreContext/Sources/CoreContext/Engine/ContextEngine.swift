//
//  ContextEngine.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

public actor ContextEngine {
    public static let shared = ContextEngine()
    
    // The engine doesn't care what these are, as long as they conform to the protocol
    private let providers: [ContextProvider] = [
        HealthProvider(),
        MotionProvider()
        // You just drop new providers in here as you build them
    ]
    
    public func authorizeAll() async {
        for provider in providers {
            try? await provider.requestAuthorization()
        }
    }
    
    public func calculateWinningContext() async -> ContextItem {
        var totalScore = 0.0
        
        // Loop through all "microservices" via the API contract
        for provider in providers {
            if let score = try? await provider.fetchCurrentState() {
                totalScore += score
            }
        }
        
        // Pass the total score to your CoreML model or logic tree here
        return ContextItem(title: "Aggregated State", category: "System", numericValue: totalScore)
    }
}
