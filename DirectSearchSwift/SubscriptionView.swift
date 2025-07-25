import SwiftUI

struct SubscriptionView: View {
    @ObservedObject var subscriptionManager = SubscriptionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.71, green: 0.94, blue: 0.64)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "infinity")
                        .font(.system(size: 60))
                        .foregroundColor(.yellow)
                    
                    Text("Upgrade to Unlimited")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Unlock unlimited access to Direct Search")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                
                // Features
                VStack(spacing: 15) {
                    FeatureRow(icon: "checkmark.circle.fill", text: "Unlimited searches across all platforms")
                    FeatureRow(icon: "checkmark.circle.fill", text: "No ads or interruptions")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Priority support")
                    FeatureRow(icon: "checkmark.circle.fill", text: "Regular updates and new features")
                }
                .padding(.horizontal, 20)
                
                // Pricing
                VStack(spacing: 10) {
                    Text("$0.99")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("per month")
                        .font(.subheadline)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("Cancel anytime")
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        Task {
                            await subscriptionManager.purchaseSubscription()
                        }
                    }) {
                        HStack {
                            if subscriptionManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(subscriptionManager.isLoading ? "Processing..." : "Subscribe Now")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(subscriptionManager.isLoading ? Color.gray : Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(subscriptionManager.isLoading)
                    
                    Button(action: {
                        Task {
                            await subscriptionManager.restorePurchases()
                        }
                    }) {
                        Text("Restore Purchases")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .disabled(subscriptionManager.isLoading)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Maybe Later")
                            .font(.subheadline)
                            .foregroundColor(.black.opacity(0.6))
                    }
                    .disabled(subscriptionManager.isLoading)
                }
                .padding(.horizontal, 20)
                
                // Terms and Privacy Links
                VStack(spacing: 8) {
                    HStack(spacing: 20) {
                        Link("Terms of Use (EULA)", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Link("Privacy Policy", destination: URL(string: "https://docs.google.com/document/d/1cMt6SDb3zureTC4BQiyKOV9N1tHM0tzQUzo7QCH3Wd4/edit?pli=1&tab=t.0")!)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 40)
        }
        .alert("Subscription", isPresented: $subscriptionManager.showSubscriptionAlert) {
            Button("OK") {
                if subscriptionManager.isSubscribed {
                    dismiss()
                }
            }
        } message: {
            Text(subscriptionManager.subscriptionAlertMessage)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.green)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
} 
