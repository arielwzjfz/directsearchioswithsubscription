import SwiftUI

struct ContentView: View {
    @State private var youtubeQuery = ""
    @State private var xiaohongshuQuery = ""
    @State private var bilibiliQuery = ""
    @State private var searchMode: SearchMode = .appSearch
    @StateObject private var searchManager = SearchManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showSubscriptionView = false
    @State private var showSettingsMenu = false
    @State private var showShareSheet = false
    @State private var showTestView = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var shouldScrollToBilibili = false
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.71, green: 0.94, blue: 0.64)
                .ignoresSafeArea()
            
            // Puppy decorations
            PuppyDecorationView()
                .position(x: UIScreen.main.bounds.width * 0.1, y: UIScreen.main.bounds.height * 0.1)
            
            PuppyDecorationView(isPink: true)
                .position(x: UIScreen.main.bounds.width * 0.9, y: UIScreen.main.bounds.height * 0.9)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 30) {
                    // Title
                    Text("Direct Search")
                        .font(.system(size: 36, weight: .bold))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(.black)
                        .padding(.top, 15)
                    
                    // Infinity symbol for subscribed users
                    if subscriptionManager.isSubscribed {
                        Image(systemName: "infinity")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .padding(.top, -10)
                    }
                    
                    // Subscription Status with real-time countdown (only for non-subscribed users)
                    if !subscriptionManager.isSubscribed {
                        SubscriptionStatusView()
                            .padding(.horizontal, 16)
                        
                        // Upgrade to Unlimited Widget
                        Button(action: {
                            showSubscriptionView = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "infinity")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                                Text("Upgrade to Unlimited")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.7))
                                    .font(.caption)
                            }
                            .padding(.vertical, 6)
                            .padding(.horizontal, 14)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    // Search Mode Toggle
                    VStack(spacing: 8) {
                        Text("Search Mode")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    searchMode = .appSearch
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "iphone")
                                        .font(.caption2)
                                    Text("App")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(searchMode == .appSearch ? .white : .black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(searchMode == .appSearch ? Color.blue : Color.white.opacity(0.9))
                                .cornerRadius(6, corners: [.topLeft, .bottomLeft])
                            }
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    searchMode = .webSearch
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe")
                                        .font(.caption2)
                                    Text("Web")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(searchMode == .webSearch ? .white : .black)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(searchMode == .webSearch ? Color.blue : Color.white.opacity(0.9))
                                .cornerRadius(6, corners: [.topRight, .bottomRight])
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.8), lineWidth: 1.5)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 1.5, x: 0, y: 0.5)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 5)
                    
                    // Search containers
                    VStack(spacing: 15) {
                        SearchBoxView(
                            platform: .youtube,
                            query: $youtubeQuery,
                            title: "YouTube",
                            placeholder: "Search YouTube...",
                            iconName: "youtube_icon",
                            searchMode: searchMode,
                            onBilibiliFocus: nil
                        )
                        
                        SearchBoxView(
                            platform: .xiaohongshu,
                            query: $xiaohongshuQuery,
                            title: "小红书",
                            placeholder: "Search 小红书...",
                            iconName: "xiaohongshu_icon",
                            searchMode: searchMode,
                            onBilibiliFocus: nil
                        )
                        
                        SearchBoxView(
                            platform: .bilibili,
                            query: $bilibiliQuery,
                            title: "Bilibili",
                            placeholder: "Search Bilibili...",
                            iconName: "bilibili_icon",
                            searchMode: searchMode,
                            onBilibiliFocus: { shouldScrollToBilibili = true }
                        )
                        .id("bilibiliSearch")
                    }
                    .padding(.horizontal, 16)
                    
                    // Bottom Buttons Row
                    HStack {
                        // Settings Button (Bottom Left)
                        Button(action: {
                            showSettingsMenu.toggle()
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color(red: 1.0, green: 0.8, blue: 0.0))
                                .clipShape(Circle())
                        }
                        .popover(isPresented: $showSettingsMenu) {
                            VStack(spacing: 15) {
                                Text("Settings")
                                    .font(.headline)
                                    .padding(.top)
                                
                                Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                                    .foregroundColor(.blue)
                                
                                Link("Privacy Policy", destination: URL(string: "https://docs.google.com/document/d/1cMt6SDb3zureTC4BQiyKOV9N1tHM0tzQUzo7QCH3Wd4/edit?pli=1&tab=t.0")!)
                                    .foregroundColor(.blue)
                                
                                Spacer()
                            }
                            .frame(width: 200, height: 150)
                        }
                        
                        Spacer()
                        
                        // Share Button (Bottom Center)
                        Button(action: {
                            showShareSheet = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title3)
                                Text("Share App")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color(red: 1.0, green: 0.8, blue: 0.0))
                            .cornerRadius(25)
                            .shadow(radius: 3)
                        }
                        
                        Spacer()
                        
                        // Invisible spacer to balance the layout
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    
                    // Add extra space at the bottom for keyboard
                    Spacer(minLength: max(100, keyboardHeight + 50))
                }
                .id("mainContent")
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                keyboardHeight = 0
            }
            .onChange(of: shouldScrollToBilibili) { shouldScroll in
                if shouldScroll {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo("bilibiliSearch", anchor: .bottom)
                    }
                    shouldScrollToBilibili = false
                }
            }
        }
        }
        .alert("App Not Installed", isPresented: $searchManager.showAppNotInstalledAlert) {
            Button("OK") { }
        } message: {
            Text(searchManager.alertMessage)
        }
        .alert("Subscription", isPresented: $subscriptionManager.showSubscriptionAlert) {
            Button("OK") {
                if !subscriptionManager.canUseApp() {
                    showSubscriptionView = true
                }
            }
        } message: {
            Text(subscriptionManager.subscriptionAlertMessage)
        }
        .sheet(isPresented: $showSubscriptionView) {
            SubscriptionView()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [
                "I found this app to eliminate distraction when searching on social media, try it out!",
                URL(string: "https://apps.apple.com/app/directsearchswift") ?? URL(string: "https://apps.apple.com")!
            ])
        }
        .sheet(isPresented: $showTestView) {
            SubscriptionTestView()
        }
        .onAppear {
            if !subscriptionManager.canUseApp() {
                showSubscriptionView = true
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    hideKeyboard()
                }
                .foregroundColor(.blue)
            }
            
            // Temporary debug button - remove after testing
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button("Reset Trial") {
                    subscriptionManager.resetForTesting()
                }
                .font(.caption)
                .foregroundColor(.red)
                
                Button("Test View") {
                    showTestView = true
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Button("Show Subscribed") {
                    subscriptionManager.forceSubscribedStateForTesting()
                }
                .font(.caption)
                .foregroundColor(.green)
            }
        }
    }
}

// Extension to create rounded corners for specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Extension to hide keyboard
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// ShareSheet for sharing functionality
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
