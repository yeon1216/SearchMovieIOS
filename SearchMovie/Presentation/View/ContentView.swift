import SwiftUI

struct ContentView: View {
    private let container: DIContainer
    private let tabItems: [TabItem] = TabItem.defaultItems()
    
    init(container: DIContainer) {
        self.container = container
    }
    
    var body: some View {
        TabView {
            ForEach(tabItems) { item in
                item.view
                    .tabItem {
                        Label(item.title, systemImage: item.systemImage)
                    }
            }
        }
        .environment(\.viewModelFactory, container.viewModelFactory)
    }
}

#Preview {
    ContentView(container: PreviewDIContainer())
}
