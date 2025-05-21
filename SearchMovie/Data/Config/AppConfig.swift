import Foundation

struct AppConfig {
    struct API {
        // OMDB API 키를 입력해주세요.
        // API 키는 https://www.omdbapi.com/apikey.aspx 에서 발급받을 수 있습니다.
        static let key = ""
        static let baseURL = "https://www.omdbapi.com/"
    }
    
    struct Storage {
        static let favoritesKey = "favoriteMovies"
    }
} 
