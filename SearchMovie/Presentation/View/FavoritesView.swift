import SwiftUI
import Combine

struct FavoritesView: View {
    @Environment(\.viewModelFactory) private var factory
    @State private var viewModel: FavoriteViewModel?
    @State private var error: Error?
    
    var body: some View {
        ZStack {
            if let error = error {
                ErrorView(error: error)
            } else if let viewModel = viewModel {
                FavoritesContentView(viewModel: viewModel)
            } else {
                ProgressView("로딩 중...")
            }
        }
        .task {
            do {
                viewModel = try await factory.makeFavoriteViewModel()
            } catch {
                self.error = error
            }
        }
    }
}

struct FavoritesContentView: View {
    @StateObject private var viewModel: FavoriteViewModel
    
    init(viewModel: FavoriteViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if viewModel.favoriteMovies.isEmpty {
                    EmptyFavoritesView()
                } else {
                    FavoriteMoviesList(
                        movies: viewModel.favoriteMovies,
                        onRemove: { movie in
                            viewModel.removeFromFavorites(movie: movie)
                        },
                        onMove: { source, destination in
                            viewModel.moveFavorite(from: source, to: destination)
                        }
                    )
                }
            }
            .navigationTitle("내 즐겨찾기")
            .environment(\.editMode, .constant(.active))
        }
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("즐겨찾기한 영화가 없습니다")
                .font(.title2)
                .foregroundColor(.gray)
                .padding()
        }
    }
}

struct FavoriteMoviesList: View {
    let movies: [MovieUIModel]
    let onRemove: (MovieUIModel) -> Void
    let onMove: (IndexSet, Int) -> Void
    @State private var draggedItem: MovieUIModel?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = (geometry.size.width - 48) / 2
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(movies) { movie in
                        FavoriteMovieCard(
                            movie: movie,
                            onRemove: onRemove,
                            width: cardWidth
                        )
                        .onDrag {
                            self.draggedItem = movie
                            return NSItemProvider(object: movie.id as NSString)
                        }
                        .onDrop(of: [.text], delegate: DropViewDelegate(
                            item: movie,
                            items: movies,
                            draggedItem: $draggedItem,
                            onMove: onMove
                        ))
                    }
                }
                .padding()
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: MovieUIModel
    let items: [MovieUIModel]
    @Binding var draggedItem: MovieUIModel?
    let onMove: (IndexSet, Int) -> Void
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else { return }
        
        if draggedItem.id != item.id {
            let from = items.firstIndex(where: { $0.id == draggedItem.id })!
            let to = items.firstIndex(where: { $0.id == item.id })!
            
            if from < to {
                onMove(IndexSet(integer: from), to + 1)
            } else {
                onMove(IndexSet(integer: from), to)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

class MockFavoriteMoviesUseCase: FavoriteMoviesUseCase {
    func updateFavoriteOrder(movies: [MovieEntity]) {}
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getFavoriteMovies() -> [MovieEntity] { [] }
    func addToFavorites(movie: MovieEntity) {}
    func removeFromFavorites(movie: MovieEntity) {}
    func updateFavoriteOrder(movie: MovieEntity) {}
}

#Preview {
    FavoritesView()
}
