import Foundation

struct MovieEntity: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let year: String
    let poster: String
    let type: String
    var ordering: Int = -1
    
    static func == (lhs: MovieEntity, rhs: MovieEntity) -> Bool {
        return lhs.id == rhs.id
    }
}