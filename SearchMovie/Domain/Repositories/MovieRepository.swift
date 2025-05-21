import Foundation
import Combine

protocol MovieRepository {
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> { get }
    func searchMovies(query: String, page: Int) async throws -> [MovieEntity]
    func getFavoriteMovies() -> [MovieEntity]
    func addToFavorites(movie: MovieEntity)
    func removeFromFavorites(movie: MovieEntity)
    func updateFavoriteOrder(movie: MovieEntity)
    func updateFavoriteOrder(movies: [MovieEntity])
}
