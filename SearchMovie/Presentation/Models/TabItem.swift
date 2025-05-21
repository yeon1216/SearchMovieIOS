import SwiftUI

struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let systemImage: String
    let view: AnyView
    
    init<V: View>(title: String, systemImage: String, @ViewBuilder view: () -> V) {
        self.title = title
        self.systemImage = systemImage
        self.view = AnyView(view())
    }
} 

extension TabItem {
    static func defaultItems() -> [TabItem] {
        [
            TabItem(title: "검색", systemImage: "magnifyingglass") {
                SearchView()
            },
            TabItem(title: "즐겨찾기", systemImage: "heart.fill") {
                FavoritesView()
            }
        ]
    }
} 
