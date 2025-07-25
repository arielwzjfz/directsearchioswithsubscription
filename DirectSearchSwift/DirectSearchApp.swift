import SwiftUI
import StoreKit

@main
struct DirectSearchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    init() {
        // Configure StoreKit for testing
        #if DEBUG
        if let storeKitConfigURL = Bundle.main.url(forResource: "product", withExtension: "storekit") {
            // StoreKit configuration is automatically loaded when the file is present
            print("🛒 StoreKit configuration file found at: \(storeKitConfigURL)")
        } else {
            print("⚠️ StoreKit configuration file not found")
        }
        #endif
    }
} 