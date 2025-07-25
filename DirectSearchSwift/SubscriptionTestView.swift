import SwiftUI
import StoreKit

struct SubscriptionTestView: View {
    @ObservedObject var storeKitManager = StoreKitManager.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @State private var debugInfo = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        // StoreKit Status
                        GroupBox("StoreKit Status") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Products Loaded: \(storeKitManager.products.count)")
                                Text("Is Subscribed: \(subscriptionManager.isSubscribed ? "Yes" : "No")")
                                Text("Free Searches: \(subscriptionManager.freeSearchesRemaining)")
                                Text("Is Purchasing: \(storeKitManager.isPurchasing ? "Yes" : "No")")
                                
                                if let error = storeKitManager.errorMessage {
                                    Text("Error: \(error)")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        
                        // Available Products
                        GroupBox("Available Products") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(storeKitManager.products, id: \.id) { product in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("ID: \(product.id)")
                                            .font(.caption)
                                        Text("Price: \(product.displayPrice)")
                                        Text("Type: \(String(describing: product.type))")
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 4)
                                    Divider()
                                }
                                
                                if storeKitManager.products.isEmpty {
                                    Text("No products available")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                        
                        // Debug Info
                        GroupBox("Debug Info") {
                            Text(debugInfo)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button("Load Products") {
                        Task {
                            await storeKitManager.loadProducts()
                            updateDebugInfo()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Test Purchase") {
                        Task {
                            await subscriptionManager.purchaseSubscription()
                            updateDebugInfo()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(storeKitManager.products.isEmpty || storeKitManager.isPurchasing)
                    
                    Button("Restore Purchases") {
                        Task {
                            await subscriptionManager.restorePurchases()
                            updateDebugInfo()
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Reset for Testing") {
                        subscriptionManager.resetForTesting()
                        updateDebugInfo()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                }
                .padding()
            }
            .navigationTitle("StoreKit Test")
            .onAppear {
                updateDebugInfo()
            }
        }
    }
    
    private func updateDebugInfo() {
        debugInfo = subscriptionManager.getTestingStatus()
    }
}

#Preview {
    SubscriptionTestView()
} 
