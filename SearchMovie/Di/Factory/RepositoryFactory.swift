import Foundation

protocol RepositoryFactory {
    func createRepository(remoteDataSource: MovieRemoteDataSource, localDataSource: MovieLocalDataSource) async -> MovieRepository
}

class DefaultRepositoryFactory: RepositoryFactory {
    func createRepository(remoteDataSource: MovieRemoteDataSource, localDataSource: MovieLocalDataSource) async -> MovieRepository {
        return await MovieRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource)
    }
} 