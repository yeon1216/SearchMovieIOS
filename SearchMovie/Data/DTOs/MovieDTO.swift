import Foundation

// API로부터 받는 영화 정보 DTO
struct MovieDTO: Codable {
    let title: String
    let year: String
    let imdbID: String
    let type: String
    let poster: String

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
        case type = "Type"
        case poster = "Poster"
    }
    
    // DTO를 도메인 엔티티로 변환하는 매퍼
    func toDomain() -> MovieEntity {
        return MovieEntity(
            id: imdbID,
            title: title,
            year: year,
            poster: poster,
            type: type
        )
    }
}

// API 응답 데이터 DTO
struct MovieSearchResponseDTO: Codable {
    let search: [MovieDTO]?
    let totalResults: String?
    let response: String

    enum CodingKeys: String, CodingKey {
        case search = "Search"
        case totalResults
        case response = "Response"
    }
} 