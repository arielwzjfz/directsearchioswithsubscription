import SwiftUI

enum SearchMode {
    case appSearch
    case webSearch
}

enum SearchPlatform {
    case youtube
    case xiaohongshu
    case bilibili
    
    var accentColor: Color {
        switch self {
        case .youtube:
            return Color(red: 0.97, green: 0.18, blue: 0.18)
        case .xiaohongshu:
            return Color(red: 1.0, green: 0.14, blue: 0.26)
        case .bilibili:
            return Color(red: 0.0, green: 0.63, blue: 0.84)
        }
    }
} 