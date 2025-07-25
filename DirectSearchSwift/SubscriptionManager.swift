import Foundation
import StoreKit
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var showSubscriptionAlert = false
    @Published var subscriptionAlertMessage = ""
    @Published var isLoading = false
    @Published var freeSearchesRemaining = 10
    
    private let userDefaults = UserDefaults.standard
    private let searchCountKey = "searchCount"
    private let maxFreeSearches = 10
    
    private let storeKitManager = StoreKitManager.shared
    private let receiptValidator = ReceiptValidator.shared
    
    private init() {
        checkSubscriptionStatus()
        updateFreeSearchesRemaining()
    }
    
    /// Reset all data - useful for testing different scenarios
    func resetForTesting() {
        userDefaults.removeObject(forKey: searchCountKey)
        checkSubscriptionStatus()
        updateFreeSearchesRemaining()
    }
    
    /// Force subscribed state for testing
    func forceSubscribedStateForTesting() {
        isSubscribed = true
        updateFreeSearchesRemaining()
    }
    
    /// Get current status for debugging
    func getTestingStatus() -> String {
        let searchCount = userDefaults.integer(forKey: searchCountKey)
        return """
        Status:
        - Search Count: \(searchCount)
        - Free Searches Remaining: \(freeSearchesRemaining)
        - Is Subscribed: \(isSubscribed)
        """
    }
    
    func checkSubscriptionStatus() {
        // Check if user has an active subscription from StoreKit
        if storeKitManager.isSubscribed() {
            // Additional server-side validation for production
            Task {
                let isValidReceipt = await receiptValidator.validateReceipt()
                if !isValidReceipt {
                    print("⚠️ Receipt validation failed, but client-side shows subscribed")
                }
            }
            isSubscribed = true
        } else {
            isSubscribed = false
        }
        updateFreeSearchesRemaining()
    }
    
    func canUseApp() -> Bool {
        return isSubscribed || freeSearchesRemaining > 0
    }
    
    func showSubscriptionRequired() {
        subscriptionAlertMessage = "You have used all 10 free searches. Subscribe for $0.99/month to continue using Direct Search."
        showSubscriptionAlert = true
    }
    
    func incrementSearchCount() {
        guard !isSubscribed else { return }
        var count = userDefaults.integer(forKey: searchCountKey)
        count += 1
        userDefaults.set(count, forKey: searchCountKey)
        updateFreeSearchesRemaining()
    }
    
    private func updateFreeSearchesRemaining() {
        let count = userDefaults.integer(forKey: searchCountKey)
        freeSearchesRemaining = max(0, maxFreeSearches - count)
    }
    
    // Real StoreKit purchase
    func purchaseSubscription() async {
        isLoading = true
        
        // Get products - now safe to access since we're @MainActor
        let availableProducts = storeKitManager.products
        guard let product = availableProducts.first else {
            subscriptionAlertMessage = "Subscription product not available. Please try again later."
            showSubscriptionAlert = true
            isLoading = false
            return
        }
        
        do {
            // Directly trigger StoreKit purchase without custom confirmation
            try await storeKitManager.purchase(product)
            isSubscribed = true
            subscriptionAlertMessage = "Thank you for subscribing! You now have unlimited access to Direct Search."
            showSubscriptionAlert = true
            updateFreeSearchesRemaining()
        } catch {
            subscriptionAlertMessage = "Purchase failed: \(error.localizedDescription)"
            showSubscriptionAlert = true
        }
        
        isLoading = false
    }
    
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await storeKitManager.restorePurchases()
            checkSubscriptionStatus()
            subscriptionAlertMessage = "Purchases restored successfully!"
            showSubscriptionAlert = true
        } catch {
            subscriptionAlertMessage = "Failed to restore purchases: \(error.localizedDescription)"
            showSubscriptionAlert = true
        }
        
        isLoading = false
    }
} 
