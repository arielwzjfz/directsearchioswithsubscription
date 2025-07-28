import Foundation
import SwiftUI

@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = true // Always true now
    @Published var showSubscriptionAlert = false
    @Published var subscriptionAlertMessage = ""
    @Published var isLoading = false
    @Published var freeSearchesRemaining = 999 // Always unlimited
    
    private let userDefaults = UserDefaults.standard
    private let searchCountKey = "searchCount"
    
    private init() {
        // Always allow unlimited searches
        isSubscribed = true
        freeSearchesRemaining = 999
    }
    
    /// Reset all data - useful for testing different scenarios
    func resetForTesting() {
        userDefaults.removeObject(forKey: searchCountKey)
        isSubscribed = true
        freeSearchesRemaining = 999
    }
    
    /// Force subscribed state for testing
    func forceSubscribedStateForTesting() {
        isSubscribed = true
        freeSearchesRemaining = 999
    }
    
    /// Get current status for debugging
    func getTestingStatus() -> String {
        let searchCount = userDefaults.integer(forKey: searchCountKey)
        return """
        Status:
        - Search Count: \(searchCount)
        - Free Searches Remaining: \(freeSearchesRemaining)
        - Is Subscribed: \(isSubscribed)
        - App is now completely free with unlimited searches!
        """
    }
    
    func checkSubscriptionStatus() {
        // Always allow unlimited searches
        isSubscribed = true
        freeSearchesRemaining = 999
    }
    
    func canUseApp() -> Bool {
        return true // Always allow usage
    }
    
    func showSubscriptionRequired() {
        // This should never be called now, but just in case
        subscriptionAlertMessage = "You have unlimited access to Direct Search! Enjoy searching across all platforms."
        showSubscriptionAlert = true
    }
    
    func incrementSearchCount() {
        // No longer needed - unlimited searches
        // Keep for compatibility but don't limit
    }
    
    private func updateFreeSearchesRemaining() {
        // Always unlimited
        freeSearchesRemaining = 999
    }
    
    // Removed all StoreKit purchase methods since app is now free
} 
