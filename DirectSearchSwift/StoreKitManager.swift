import Foundation
import StoreKit
import SwiftUI

@MainActor
class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs = Set<String>()
    @Published var isPurchasing = false
    @Published var errorMessage: String?
    
    private let productIDs = [
        "com.arielwu.DirectSearchSwift.unlimited.monthly"
    ]
    
    private init() {
        print("🛒 StoreKitManager initialized")
        print("🛒 Product IDs: \(productIDs)")
        print("🛒 Environment: \(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? "Preview" : "Production")")
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    func loadProducts() async {
        print("🛒 Loading products...")
        do {
            products = try await Product.products(for: productIDs)
            print("🛒 Loaded \(products.count) products")
            for product in products {
                print("🛒 Product: \(product.id) - \(product.displayPrice)")
            }
        } catch {
            print("🛒 Failed to load products: \(error)")
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }
    
    func updatePurchasedProducts() async {
        print("🛒 Updating purchased products...")
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                print("🛒 Transaction verification failed")
                continue
            }
            print("🛒 Found purchased product: \(transaction.productID)")
            purchasedProductIDs.insert(transaction.productID)
        }
        print("🛒 Purchased products: \(purchasedProductIDs)")
    }
    
    func purchase(_ product: Product) async throws {
        isPurchasing = true
        defer { isPurchasing = false }
        
        print("🛒 Starting purchase for: \(product.id)")
        print("🛒 Product price: \(product.displayPrice)")
        print("🛒 Product type: \(product.type)")
        print("🛒 Environment: \(ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" ? "Preview" : "Production")")
        
        let result = try await product.purchase()
        
        print("🛒 Purchase result: \(result)")
        
        switch result {
        case .success(let verification):
            print("🛒 Purchase successful, verifying...")
            guard case .verified(let transaction) = verification else {
                print("🛒 Verification failed")
                throw StoreError.failedVerification
            }
            
            print("🛒 Transaction verified: \(transaction.id)")
            print("🛒 Transaction date: \(transaction.purchaseDate)")
            print("🛒 Transaction original ID: \(transaction.originalID)")
            
            // Update the user's purchases
            await updatePurchasedProducts()
            
            // Finish the transaction
            await transaction.finish()
            print("🛒 Transaction finished")
            
        case .userCancelled:
            print("🛒 Purchase cancelled by user")
            throw StoreError.userCancelled
        case .pending:
            print("🛒 Purchase pending")
            throw StoreError.pending
        @unknown default:
            print("🛒 Unknown purchase result")
            throw StoreError.unknown
        }
    }
    
    func restorePurchases() async throws {
        print("🛒 Restoring purchases...")
        try await AppStore.sync()
        await updatePurchasedProducts()
        print("🛒 Purchases restored")
    }
    
    func isSubscribed() -> Bool {
        let subscribed = !purchasedProductIDs.isEmpty
        print("🛒 Is subscribed: \(subscribed)")
        return subscribed
    }
}

enum StoreError: LocalizedError {
    case failedVerification
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending"
        case .unknown:
            return "Unknown error occurred"
        }
    }
} 
