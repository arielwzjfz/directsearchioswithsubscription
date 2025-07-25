import SwiftUI

struct SearchBoxView: View {
    let platform: SearchPlatform
    @Binding var query: String
    let title: String
    let placeholder: String
    let iconName: String
    let searchMode: SearchMode
    
    @State private var isSearching = false
    @FocusState private var isTextFieldFocused: Bool
    
    // Callback for when Bilibili field gets focus
    var onBilibiliFocus: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .cornerRadius(3)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            
            // Search input and button
            HStack(spacing: 8) {
                TextField(placeholder, text: $query)
                    .font(.subheadline)
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isTextFieldFocused ? platform.accentColor : Color(UIColor.systemGray4), lineWidth: isTextFieldFocused ? 2 : 1)
                    )
                    .focused($isTextFieldFocused)
                    .onChange(of: isTextFieldFocused) { focused in
                        if focused && platform == .bilibili {
                            onBilibiliFocus?()
                        }
                    }
                    .onSubmit {
                        performSearch()
                        isTextFieldFocused = false
                    }
                    .accentColor(.black)
                
                Button(action: performSearch) {
                    Text("Search")
                        .fontWeight(.semibold)
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(platform.accentColor)
                        .cornerRadius(6)
                }
                .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1.5)
        .overlay(
            Rectangle()
                .frame(width: 3)
                .foregroundColor(platform.accentColor)
                .cornerRadius(1.5),
            alignment: .leading
        )
        .scaleEffect(isSearching ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSearching)
        .onTapGesture {
            if isTextFieldFocused {
                isTextFieldFocused = false
            }
        }
    }
    
    private func performSearch() {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        isSearching = true
        
        // Perform the search using the SearchManager with the current search mode
        SearchManager.shared.performSearch(platform: platform, query: trimmedQuery, mode: searchMode)
        
        // Reset the search state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isSearching = false
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchBoxView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchBoxView(
                platform: .youtube,
                query: .constant(""),
                title: "YouTube",
                placeholder: "Search YouTube...",
                iconName: "youtube_icon",
                searchMode: .appSearch
            )
            
            SearchBoxView(
                platform: .xiaohongshu,
                query: .constant(""),
                title: "小红书",
                placeholder: "Search 小红书...",
                iconName: "xiaohongshu_icon",
                searchMode: .webSearch
            )
            
            SearchBoxView(
                platform: .bilibili,
                query: .constant(""),
                title: "Bilibili",
                placeholder: "Search Bilibili...",
                iconName: "bilibili_icon",
                searchMode: .appSearch
            )
        }
        .padding()
        .background(Color(red: 0.71, green: 0.94, blue: 0.64))
    }
}
