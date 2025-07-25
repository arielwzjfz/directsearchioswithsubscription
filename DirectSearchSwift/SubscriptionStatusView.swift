import SwiftUI

struct SubscriptionStatusView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        VStack(spacing: 8) {
            if !subscriptionManager.isSubscribed && subscriptionManager.freeSearchesRemaining > 0 {
                // Free searches remaining
                HStack(spacing: 12) {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                        .font(.subheadline)
                    
                    Text("Free Searches")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    
                    Text("\(subscriptionManager.freeSearchesRemaining) left")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .id(subscriptionManager.freeSearchesRemaining)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
            } else if !subscriptionManager.isSubscribed {
                // No free searches left
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    
                    Text("Free Searches Used Up")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("Subscribe to continue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                )
            } else {
                // Subscribed status - single line
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline)
                    
                    Text("Unlimited Access")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text("Active Subscription")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    SubscriptionStatusView()
        .padding()
} 
