import Foundation
import Combine

protocol MovieLocalDataSource {
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> { get }
    func getFavoriteMovies() -> [MovieEntity]
    func addToFavorites(movie: MovieEntity)
    func removeFromFavorites(movie: MovieEntity)
    func updateFavoriteOrder(movie: MovieEntity)
    func updateFavoriteOrder(movies: [MovieEntity])
}

class MovieLocalDataSourceImpl: MovieLocalDataSource, ObservableObject {
    private let favoritesKey = "favoriteMovies"
    @Published private var favorites: [MovieEntity] = []
    
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> {
        $favorites.eraseToAnyPublisher()
    }
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([MovieEntity].self, from: data) {
            favorites = decoded.sorted { ($0.ordering) < ($1.ordering) }
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func getFavoriteMovies() -> [MovieEntity] {
        return favorites.sorted { $0.ordering < $1.ordering }
    }
    
    func addToFavorites(movie: MovieEntity) {
        if movie.ordering < 0 {
            var newMovie = movie
            newMovie.ordering = favorites.count
            favorites.append(newMovie)
            saveFavorites()
        }
    }
    
    func removeFromFavorites(movie: MovieEntity) {
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites.remove(at: index)
            for i in index..<favorites.count {
                favorites[i].ordering = i
            }
            saveFavorites()
        }
    }
    
    func updateFavoriteOrder(movie: MovieEntity) {
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites[index].ordering = movie.ordering
            saveFavorites()
        }
    }
    
    func updateFavoriteOrder(movies: [MovieEntity]) {
        favorites = movies
        saveFavorites()
    }
} 
