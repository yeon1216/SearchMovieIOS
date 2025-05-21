import Foundation
import Combine
import UIKit

@MainActor
final class FavoriteViewModel: ObservableObject {
    @Published private(set) var favoriteMovies: [MovieUIModel] = []
    @Published private(set) var isLoading = false
    
    private let favoriteUseCase: FavoriteMoviesUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(favoriteUseCase: FavoriteMoviesUseCase) {
        self.favoriteUseCase = favoriteUseCase
        setupBindings()
    }
    
    private func setupBindings() {
        favoriteUseCase.favoritesPublisher
            .sink { [weak self] movies in
                guard let self = self else { return }
                if self.favoriteMovies.map({ $0.id }) != movies.map({ $0.id }) {
                    self.loadFavorites()
                }
            }
            .store(in: &cancellables)
    }
    
    func loadFavorites() {
        Task {
            isLoading = true
            let entities = favoriteUseCase.getFavoriteMovies()
            favoriteMovies = await convertToUIModels(entities)
            isLoading = false
        }
    }
    
    private func loadImage(from url: URL) async throws -> UIImage {
        return try await ImageCacheManager.shared.loadImage(from: url)
    }
    
    private func convertToUIModels(_ entities: [MovieEntity]) async -> [MovieUIModel] {
        var uiModels: [MovieUIModel] = []
        
        for entity in entities {
            var uiModel = MovieUIModel(entity: entity)
            if let posterURL = uiModel.posterURL {
                do {
                    let image = try await loadImage(from: posterURL)
                    uiModel.posterImage = image
                } catch {
                    print("Failed to load image: \(error)")
                }
            }
            uiModels.append(uiModel)
        }
        
        return uiModels
    }
     
     
    func removeFromFavorites(movie: MovieUIModel) {
        let entity = MovieEntity(
            id: movie.id,
            title: movie.title,
            year: movie.year,
            poster: movie.posterURL?.absoluteString ?? "",
            type: movie.type
        )
        
        favoriteUseCase.removeFromFavorites(movie: entity)
    }
    
    func moveFavorite(from source: IndexSet, to destination: Int) {
        favoriteMovies.move(fromOffsets: source, toOffset: destination)
        
        // 새로운 순서로 MovieEntity 배열 생성
        let updatedEntities = favoriteMovies.enumerated().map { index, movie in
            var movie = MovieEntity(
                id: movie.id,
                title: movie.title,
                year: movie.year,
                poster: movie.posterURL?.absoluteString ?? "",
                type: movie.type
            )
            movie.ordering = index
            return movie
        }

        favoriteUseCase.updateFavoriteOrder(movies: updatedEntities)
    }
}

// MARK: - Preview Helpers
extension FavoriteViewModel {
    static var preview: FavoriteViewModel {
        FavoriteViewModel(favoriteUseCase: PreviewFavoriteMoviesUseCase())
    }
}

private struct PreviewFavoriteMoviesUseCase: FavoriteMoviesUseCase {
    func updateFavoriteOrder(movies: [MovieEntity]) {}
    
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getFavoriteMovies() -> [MovieEntity] {
        return [
            MovieEntity(
                id: "tt0468569",
                title: "다크 나이트",
                year: "2008",
                poster: "https://example.com/poster.jpg",
                type: "movie"
            )
        ]
    }
    
    func addToFavorites(movie: MovieEntity) {}
    func removeFromFavorites(movie: MovieEntity) {}
    func updateFavoriteOrder(movie: MovieEntity) {}
}

