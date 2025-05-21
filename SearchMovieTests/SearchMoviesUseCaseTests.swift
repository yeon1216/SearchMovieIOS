import XCTest
import Combine
@testable import SearchMovie

class SearchMoviesUseCaseTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    var useCase: SearchMoviesUseCase!

    override func setUp() {
        super.setUp()
        // 실제 네트워크가 아닌 Mock DataSource/Repository를 주입하는 것이 이상적입니다.
        let remote = DefaultMovieRemoteDataSource()
        let local = DefaultMovieLocalDataSource()
        let repository = DefaultMovieRepository(remoteDataSource: remote, localDataSource: local)
        useCase = DefaultSearchMoviesUseCase(repository: repository)
    }

    func testSearchMovies() {
        let expectation = self.expectation(description: "영화 검색 네트워크 응답")
        var result: [MovieEntity]?
        var errorResult: Error?

        useCase.execute(query: "batman")
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    errorResult = error
                }
                expectation.fulfill()
            }, receiveValue: { movies in
                result = movies
            })
            .store(in: &cancellables)

        waitForExpectations(timeout: 5)
        XCTAssertNil(errorResult)
        XCTAssertNotNil(result)
        XCTAssertTrue(result?.count ?? 0 > 0)
    }
} 
