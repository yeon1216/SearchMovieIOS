import Foundation
import SwiftUI

protocol DIContainer {
    var viewModelFactory: ViewModelFactory { get }
}

class AppDIContainer: DIContainer {
    let viewModelFactory: ViewModelFactory
    
    private let dataSourceFactory: DataSourceFactory
    private let repositoryFactory: RepositoryFactory
    private let useCaseFactory: UseCaseFactory
    
    init(
        dataSourceFactory: DataSourceFactory = DefaultDataSourceFactory(),
        repositoryFactory: RepositoryFactory = DefaultRepositoryFactory(),
        useCaseFactory: UseCaseFactory = DefaultUseCaseFactory()
    ) async {
        self.dataSourceFactory = dataSourceFactory
        self.repositoryFactory = repositoryFactory
        self.useCaseFactory = useCaseFactory
        
        let remote = dataSourceFactory.createRemoteDataSource()
        let local = await dataSourceFactory.createLocalDataSource()
        let repository = await repositoryFactory.createRepository(
            remoteDataSource: remote,
            localDataSource: local
        )
        
        let searchUseCase = useCaseFactory.createSearchUseCase(repository: repository)
        let favoriteUseCase = useCaseFactory.createFavoriteUseCase(repository: repository)
        
        self.viewModelFactory = DefaultViewModelFactory(
            searchUseCase: searchUseCase,
            favoriteUseCase: favoriteUseCase
        )
    }
}

#if DEBUG
class PreviewDIContainer: DIContainer {
    let viewModelFactory: ViewModelFactory = DefaultViewModelFactory(
        searchUseCase: MockSearchMoviesUseCase(),
        favoriteUseCase: MockFavoriteMoviesUseCase()
    )
}
#endif 

