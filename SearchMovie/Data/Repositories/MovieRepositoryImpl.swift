import Foundation
import Combine

class MovieRepositoryImpl: MovieRepository {
    private let remoteDataSource: MovieRemoteDataSource
    private let localDataSource: MovieLocalDataSource
    
    var favoritesPublisher: AnyPublisher<[MovieEntity], Never> {
        localDataSource.favoritesPublisher
    }
    
    init(remoteDataSource: MovieRemoteDataSource, localDataSource: MovieLocalDataSource) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func searchMovies(query: String, page: Int) async throws -> [MovieEntity] {
        let response = try await remoteDataSource.searchMovies(query: query, page: page)
        return response.search?.map { $0.toDomain() } ?? []
    }
    
    func getFavoriteMovies() -> [MovieEntity] {
        return localDataSource.getFavoriteMovies()
    }
    
    func addToFavorites(movie: MovieEntity) {
        localDataSource.addToFavorites(movie: movie)
    }
    
    func removeFromFavorites(movie: MovieEntity) {
        localDataSource.removeFromFavorites(movie: movie)
    }

    func updateFavoriteOrder(movie: MovieEntity) {
        localDataSource.updateFavoriteOrder(movie: movie)
    }
    
    func updateFavoriteOrder(movies: [MovieEntity]) {
        localDataSource.updateFavoriteOrder(movies: movies)
    }
} 
