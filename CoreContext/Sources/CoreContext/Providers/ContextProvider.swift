//
//  ContextProvider.swift
//  CoreContext
//
//  Created by Spencer Dearman on 4/15/26.
//

// This is your internal API contract
import Foundation

// Adding 'Sendable' guarantees thread safety to the compiler
public protocol ContextProvider: Sendable {
    var providerName: String { get }
    func requestAuthorization() async throws
    func fetchCurrentState() async throws -> Double
}
