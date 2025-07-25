import Foundation

class ReceiptValidator: ObservableObject {
    static let shared = ReceiptValidator()
    
    private let productionURL = "https://buy.itunes.apple.com/verifyReceipt"
    private let sandboxURL = "https://sandbox.itunes.apple.com/verifyReceipt"
    
    private init() {}
    
    func validateReceipt() async -> Bool {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            print("❌ No receipt found")
            return false
        }
        
        let receiptString = receiptData.base64EncodedString()
        
        // Try production first
        if await validateReceiptWithServer(receiptString, url: productionURL) {
            return true
        }
        
        // If production fails with sandbox error, try sandbox
        return await validateReceiptWithServer(receiptString, url: sandboxURL)
    }
    
    private func validateReceiptWithServer(_ receiptString: String, url: String) async -> Bool {
        let requestBody: [String: Any] = [
            "receipt-data": receiptString,
            "password": "64a8e71a46a747a6bcb40ceeb6d39251", // Replace this with your actual shared secret from App Store Connect
            "exclude-old-transactions": true
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody),
              let requestURL = URL(string: url) else {
            return false
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            if let status = response?["status"] as? Int {
                switch status {
                case 0: // Valid receipt
                    print("✅ Receipt validation successful")
                    return true
                case 21007: // Sandbox receipt used in production
                    print("⚠️ Sandbox receipt detected")
                    return false
                default:
                    print("❌ Receipt validation failed with status: \(status)")
                    return false
                }
            }
        } catch {
            print("❌ Receipt validation error: \(error)")
        }
        
        return false
    }
} 