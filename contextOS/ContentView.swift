//
//  ContentView.swift
//  contextOS
//
//  Created by Spencer Dearman on 4/15/26.
//

import SwiftUI
import SwiftData
import CoreContext

struct ContentView: View {
    // 1. Access the SwiftData context and query existing items
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ContextItem.timestamp, order: .reverse) private var contextItems: [ContextItem]
    
    @State private var isFetching = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Minimalist background
                Color(white: 0.95).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Manual Trigger Section
                    Button(action: {
                        Task {
                            await runHealthDataTest()
                        }
                    }) {
                        HStack {
                            Text(isFetching ? "Fetching Data..." : "Fetch Sleep Data")
                                .fontWeight(.semibold)
                            if isFetching {
                                Spacer()
                                ProgressView()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 5)
                    }
                    .disabled(isFetching)
                    .padding(.horizontal)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                    
                    // Database Results Section
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if contextItems.isEmpty {
                                Text("No context data saved yet.")
                                    .foregroundColor(.gray)
                                    .padding(.top, 40)
                            } else {
                                ForEach(contextItems) { item in
                                    ContextCardView(item: item)
                                        .contextMenu {
                                            Button("Delete", role: .destructive) {
                                                modelContext.delete(item)
                                            }
                                        }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("ContextOS v1")
            }
        }
    }
    
    // 2. The Test Function: Fetch from HealthKit, Save to SwiftData
    private func runHealthDataTest() async {
        isFetching = true
        errorMessage = nil
        
        // 1. Authorize ALL providers (HealthKit, CoreMotion, etc.) at once
        await ContextEngine.shared.authorizeAll()
        
        // 2. Let the engine calculate the score and build the card
        let newItem = await ContextEngine.shared.calculateWinningContext()
        
        // 3. Save the resulting card to SwiftData
        modelContext.insert(newItem)
        
        isFetching = false
    }
}

// Custom modern card view for the items
struct ContextCardView: View {
    let item: ContextItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(item.category.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
                Text(item.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Text(item.title)
                .font(.headline)
            
            if let hours = item.numericValue {
                Text("\(String(format: "%.2f", hours)) Hours")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 4)
    }
}

#Preview {
    ContentView()
    // Provide a temporary in-memory container just for the canvas preview
        .modelContainer(for: ContextItem.self, inMemory: true)
}
