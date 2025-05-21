import Foundation

protocol DataSourceFactory {
    func createRemoteDataSource() -> MovieRemoteDataSource
    func createLocalDataSource() async -> MovieLocalDataSource
}

class DefaultDataSourceFactory: DataSourceFactory {
    private static var localDataSourceInstance: MovieLocalDataSource?
    
    func createRemoteDataSource() -> MovieRemoteDataSource {
        return MovieRemoteDataSourceImpl()
    }
    
    func createLocalDataSource() async -> MovieLocalDataSource {
        if let instance = DefaultDataSourceFactory.localDataSourceInstance {
            return instance
        }
        let instance = await MovieLocalDataSourceImpl()
        DefaultDataSourceFactory.localDataSourceInstance = instance
        return instance
    }
} 