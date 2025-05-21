import Foundation

protocol MovieRemoteDataSource {
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponseDTO
}

class MovieRemoteDataSourceImpl: MovieRemoteDataSource {
    func searchMovies(query: String, page: Int) async throws -> MovieSearchResponseDTO {
        var urlComponents = URLComponents(string: AppConfig.API.baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "apikey", value: AppConfig.API.key),
            URLQueryItem(name: "s", value: query),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(MovieSearchResponseDTO.self, from: data)
    }
} 