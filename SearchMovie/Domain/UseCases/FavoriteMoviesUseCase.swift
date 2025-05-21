import Foundation
import Combine

protocol FavoriteMoviesUseCase {
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> { get }
    func getFavoriteMovies() -> [MovieEntity]
    func addToFavorites(movie: MovieEntity)
    func removeFromFavorites(movie: MovieEntity)
    func updateFavoriteOrder(movie: MovieEntity)
    func updateFavoriteOrder(movies: [MovieEntity])
}

final class FavoriteMoviesUseCaseImpl: FavoriteMoviesUseCase {
    private let repository: MovieRepository
    
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> {
        repository.favoritesPublisher
    }
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func getFavoriteMovies() -> [MovieEntity] {
        return repository.getFavoriteMovies()
    }
    
    func addToFavorites(movie: MovieEntity) {
        repository.addToFavorites(movie: movie)
    }
    
    func removeFromFavorites(movie: MovieEntity) {
        repository.removeFromFavorites(movie: movie)
    }
    
    func updateFavoriteOrder(movie: MovieEntity) {
        repository.updateFavoriteOrder(movie: movie)
    }
    
    func updateFavoriteOrder(movies: [MovieEntity]) {
        repository.updateFavoriteOrder(movies: movies)
    }
}