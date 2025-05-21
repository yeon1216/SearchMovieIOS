import Foundation

protocol UseCaseFactory {
    func createSearchUseCase(repository: MovieRepository) -> SearchMoviesUseCase
    func createFavoriteUseCase(repository: MovieRepository) -> FavoriteMoviesUseCase
}

class DefaultUseCaseFactory: UseCaseFactory {
    func createSearchUseCase(repository: MovieRepository) -> SearchMoviesUseCase {
        return SearchMoviesUseCaseImpl(repository: repository)
    }
    
    func createFavoriteUseCase(repository: MovieRepository) -> FavoriteMoviesUseCase {
        return FavoriteMoviesUseCaseImpl(repository: repository)
    }
} 