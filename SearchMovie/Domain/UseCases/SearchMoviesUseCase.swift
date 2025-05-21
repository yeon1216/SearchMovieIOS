import Foundation

protocol SearchMoviesUseCase {
    func execute(query: String, page: Int) async throws -> [MovieEntity]
}

final class SearchMoviesUseCaseImpl: SearchMoviesUseCase {
    private let repository: MovieRepository
    
    init(repository: MovieRepository) {
        self.repository = repository
    }
    
    func execute(query: String, page: Int) async throws -> [MovieEntity] {
        return try await repository.searchMovies(query: query, page: page)
    }
} 