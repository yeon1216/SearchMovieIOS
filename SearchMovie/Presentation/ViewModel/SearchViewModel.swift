import Foundation
import Combine
import UIKit

@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var movies: [MovieUIModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var hasMorePages = true
    @Published private(set) var hasSearched = false
    @Published private(set) var favoriteIds = Set<String>()
    
    private let searchUseCase: SearchMoviesUseCase
    private let favoriteUseCase: FavoriteMoviesUseCase
    private var currentPage = 1
    private var currentQuery = ""
    private var cancellables = Set<AnyCancellable>()
    
    init(searchUseCase: SearchMoviesUseCase, favoriteUseCase: FavoriteMoviesUseCase) {
        self.searchUseCase = searchUseCase
        self.favoriteUseCase = favoriteUseCase
        setupBindings()
    }
    
    private func setupBindings() {
        favoriteUseCase.favoritesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteMovies in
                guard let self = self else { return }
                self.favoriteIds = Set(favoriteMovies.map { $0.id })
                for (index, movie) in self.movies.enumerated() {
                    self.movies[index].isFavorite = favoriteIds.contains(movie.id)
                }
            }
            .store(in: &cancellables)
    }
    
    func searchMovies(query: String) {
        guard !query.isEmpty else {
            movies = []
            hasSearched = false
            return
        }
        
        // 새로운 검색일 경우 상태 초기화
        if query != currentQuery {
            movies = []
            currentPage = 1
            hasMorePages = true
            hasSearched = true
        }
        
        currentQuery = query
        
        Task {
            await searchMoviesForCurrentPage()
        }
    }
    
    private func searchMoviesForCurrentPage() async {
        guard !isLoading && hasMorePages else { return }
        
        isLoading = true
        error = nil
        
        do {
            let newMovies = try await searchUseCase.execute(query: currentQuery, page: currentPage)
            if newMovies.isEmpty {
                hasMorePages = false
            } else {
                let newUIModels = await convertToUIModels(newMovies)
                movies.append(contentsOf: newUIModels)
                currentPage += 1
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
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
                    uiModel.isFavorite = favoriteIds.contains(entity.id)
                } catch {
                    print("Failed to load image: \(error)")
                }
            }
            uiModels.append(uiModel)
        }
        
        return uiModels
    }
    
    func loadMoreIfNeeded(currentItem: MovieUIModel?) {
        guard let currentItem = currentItem else { return }
        
        let thresholdIndex = movies.index(movies.endIndex, offsetBy: -5)
        if movies.firstIndex(where: { $0.id == currentItem.id }) ?? 0 >= thresholdIndex {
            Task {
                await searchMoviesForCurrentPage()
            }
        }
    }
    
    func toggleFavorite(movie: MovieUIModel) {
        Task {
            let entity = MovieEntity(
                id: movie.id,
                title: movie.title,
                year: movie.year,
                poster: movie.posterURL?.absoluteString ?? "",
                type: movie.type
            )
            if movie.isFavorite {
                favoriteUseCase.removeFromFavorites(movie: entity)
            } else {
                favoriteUseCase.addToFavorites(movie: entity)
            }
        }
    }
}

// MARK: - Preview Helpers
extension SearchViewModel {
    static var preview: SearchViewModel {
        SearchViewModel(
            searchUseCase: PreviewSearchMoviesUseCase(),
            favoriteUseCase: PreviewFavoriteMoviesUseCase()
        )
    }
}

private struct PreviewSearchMoviesUseCase: SearchMoviesUseCase {
    func execute(query: String, page: Int) async throws -> [MovieEntity] {
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
}

private struct PreviewFavoriteMoviesUseCase: FavoriteMoviesUseCase {
    func updateFavoriteOrder(movies: [MovieEntity]) {}
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> {
        Empty().eraseToAnyPublisher()
    }
    
    func getFavoriteMovies() -> [MovieEntity] { [] }
    func addToFavorites(movie: MovieEntity) {}
    func removeFromFavorites(movie: MovieEntity) {}
    func updateFavoriteOrder(movie: MovieEntity) {}
}

