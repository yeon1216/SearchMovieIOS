import Foundation
import UIKit

struct MovieUIModel: Identifiable, Equatable {
    let id: String
    let title: String
    let year: String
    let posterURL: URL?
    let type: String
    let ordering: Int // ordering이 0 이상이면 즐겨찾는 영화
    var isFavorite: Bool = false
    var posterImage: UIImage?
    
    init(entity: MovieEntity) {
        self.id = entity.id
        self.title = entity.title
        self.year = MovieUIModel.year_format(entity.year)
        self.posterURL = URL(string: entity.poster)
        self.type = MovieUIModel.type_format(entity.type)
        self.ordering = entity.ordering
        if ordering >= 0 {
            self.isFavorite = true
        }
    }
    
    private static func year_format(_ year: String) -> String {
        let components = year.components(separatedBy: "–")
        if components.count > 1 {
            return "\(components[0])~\(components[1])"
        }
        return year
    }
    
    private static func type_format(_ type: String) -> String {
        switch type.lowercased() {
        case "movie":
            return "영화"
        case "series":
            return "시리즈"
        case "episode":
            return "에피소드"
        default:
            return type
        }
    }
}

// 미리보기용 더미 데이터
extension MovieUIModel {
    static let dummy = MovieUIModel(
        entity: MovieEntity(
            id: "tt0468569",
            title: "다크 나이트",
            year: "2008",
            poster: "https://example.com/poster.jpg",
            type: "movie"
        )
    )
} 
