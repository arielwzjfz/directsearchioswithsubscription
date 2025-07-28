import Foundation
import UIKit
import SwiftUI
@MainActor
class SearchManager: ObservableObject {
    static let shared = SearchManager()
    
    @Published var showAppNotInstalledAlert = false
    @Published var alertMessage = ""
    
    private init() {}
    
    func performSearch(platform: SearchPlatform, query: String, mode: SearchMode) {
        // App is now completely free - no subscription checks needed
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let (appUrl, webUrl) = getUrls(for: platform, query: encodedQuery)
        
        switch mode {
        case .appSearch:
            // App Search: Try to open the app, no fallback to web
            openAppOnly(appUrl: appUrl, webUrl: webUrl, platform: platform)
        case .webSearch:
            // Web Search: Always open in web browser
            openWebUrl(webUrl)
        }
    }
    
    private func getUrls(for platform: SearchPlatform, query: String) -> (appUrl: URL?, webUrl: URL) {
        switch platform {
        case .youtube:
            let appUrl = URL(string: "youtube://results?search_query=\(query)")
            let webUrl = URL(string: "https://www.youtube.com/results?search_query=\(query)")!
            return (appUrl, webUrl)
            
        case .xiaohongshu:
            let appUrl = URL(string: "xhsdiscover://search/result?keyword=\(query)")
            let webUrl = URL(string: "https://www.xiaohongshu.com/search_result?keyword=\(query)")!
            return (appUrl, webUrl)
            
        case .bilibili:
            let appUrl = URL(string: "bilibili://search?keyword=\(query)")
            let webUrl = URL(string: "https://search.bilibili.com/all?keyword=\(query)")!
            return (appUrl, webUrl)
        }
    }
    
    private func openAppOnly(appUrl: URL?, webUrl: URL, platform: SearchPlatform) {
        guard let appUrl = appUrl else {
            // If no app URL is available, show an alert
            alertMessage = "App URL scheme not available for this platform"
            showAppNotInstalledAlert = true
            return
        }
        
        // Try to open the app without fallback
        UIApplication.shared.open(appUrl, options: [:]) { success in
            DispatchQueue.main.async {
                if !success {
                    // If the app is not installed, show an alert
                    let platformName = self.getPlatformName(platform)
                    self.alertMessage = "\(platformName) app is not installed on your device. Please install it from the App Store or switch to Web Search mode."
                    self.showAppNotInstalledAlert = true
                }
            }
        }
    }
    
    private func getPlatformName(_ platform: SearchPlatform) -> String {
        switch platform {
        case .youtube:
            return "YouTube"
        case .xiaohongshu:
            return "小红书"
        case .bilibili:
            return "Bilibili"
        }
    }
    
    private func openWebUrl(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
} 
