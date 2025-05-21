import SwiftUI

struct SearchView: View {
    @Environment(\.viewModelFactory) private var factory
    @State private var viewModel: SearchViewModel?
    @State private var error: Error?
    
    var body: some View {
        ZStack {
            if let error = error {
                ErrorView(error: error)
            } else if let viewModel = viewModel {
                SearchContentView(viewModel: viewModel)
            } else {
                ProgressView("로딩 중...")
            }
        }
        .task {
            do {
                viewModel = try await factory.makeSearchViewModel()
            } catch {
                self.error = error
            }
        }
    }
}

struct SearchContentView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var searchText = ""
    
    init(viewModel: SearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearch: { query in
                    viewModel.searchMovies(query: query)
                })
                
                if viewModel.isLoading && viewModel.movies.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if let error = viewModel.error {
                    ErrorView(error: error)
                } else {
                    MovieGridView(
                        movies: viewModel.movies,
                        onFavoriteToggle: { movie in
                            viewModel.toggleFavorite(movie: movie)
                        },
                        viewModel: viewModel
                    )
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    let onSearch: (String) -> Void
    
    var body: some View {
        HStack {
            TextField("영화 제목을 입력하세요", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.search)
                .onSubmit {
                    hideKeyboard()
                    onSearch(text)
                }
            
            Button(action: {
                hideKeyboard()
                onSearch(text)
            }) {
                Image(systemName: "magnifyingglass")
            }
        }
        .padding()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct MovieGridView: View {
    let movies: [MovieUIModel]
    let onFavoriteToggle: (MovieUIModel) -> Void
    @ObservedObject var viewModel: SearchViewModel
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = (geometry.size.width - 48) / 2
            
            ScrollView {
                if movies.isEmpty && !viewModel.isLoading {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                        
                        Text("검색 결과가 없습니다.")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(movies) { movie in
                            SearchMovieCard(
                                movie: movie,
                                onFavoriteToggle: onFavoriteToggle,
                                width: cardWidth
                            )
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentItem: movie)
                            }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct ErrorView: View {
    let error: Error
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text("오류가 발생했습니다")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

// 프리뷰용 Mock
class MockSearchMoviesUseCase: SearchMoviesUseCase {
    func execute(query: String, page: Int) async throws -> [MovieEntity] { [] }
}

#Preview {
    SearchView()
}
