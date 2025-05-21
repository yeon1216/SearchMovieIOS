import SwiftUI

// MARK: - ViewModelFactory Protocol
protocol ViewModelFactory {
    func makeSearchViewModel() async throws -> SearchViewModel
    func makeFavoriteViewModel() async throws -> FavoriteViewModel
}

// MARK: - Default Implementation
final class DefaultViewModelFactory: ViewModelFactory {
    private let searchUseCase: SearchMoviesUseCase
    private let favoriteUseCase: FavoriteMoviesUseCase
    
    init(searchUseCase: SearchMoviesUseCase, favoriteUseCase: FavoriteMoviesUseCase) {
        self.searchUseCase = searchUseCase
        self.favoriteUseCase = favoriteUseCase
    }
    
    func makeSearchViewModel() async throws -> SearchViewModel {
        return await SearchViewModel(
            searchUseCase: searchUseCase,
            favoriteUseCase: favoriteUseCase
        )
    }
    
    func makeFavoriteViewModel() async throws -> FavoriteViewModel {
        return await FavoriteViewModel(
            favoriteUseCase: favoriteUseCase
        )
    }
}

// MARK: - Environment Key
private struct ViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: ViewModelFactory = DefaultViewModelFactory(
        searchUseCase: MockSearchMoviesUseCase(),
        favoriteUseCase: MockFavoriteMoviesUseCase()
    )
}

// MARK: - Environment Values Extension
extension EnvironmentValues {
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }
} 
