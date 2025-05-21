import SwiftUI

@main
struct SearchMovieApp: App {
    @State private var container: DIContainer?
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if let container {
                    ContentView(container: container)
                } else {
                    ProgressView("초기화 중...")
                        .task {
                            container = await AppDIContainer()
                        }
                }
            }
        }
    }
}
