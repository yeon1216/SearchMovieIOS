import SwiftUI

// MARK: - Base MovieCard
struct BaseMovieCard: View {
    let movie: MovieUIModel
    let icon: AnyView?
    let onTap: () -> Void
    let width: CGFloat
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if let cachedImage = movie.posterImage {
                    Image(uiImage: cachedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                } else {
                    AsyncImage(url: movie.posterURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                            .frame(height: 200)
                    }
                }
                Spacer(minLength: 0)
                VStack(alignment: .leading, spacing: 4) {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(movie.year)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(movie.type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .frame(width: width)
            icon
        }
        .frame(width: width, height: 270)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .onTapGesture(perform: onTap)
    }
}

// MARK: - Search MovieCard
struct SearchMovieCard: View {
    let movie: MovieUIModel
    let onFavoriteToggle: (MovieUIModel) -> Void
    let width: CGFloat
    @State private var showingSheet = false
    
    var body: some View {
        BaseMovieCard(
            movie: movie,
            icon: AnyView(
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(.white)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: movie.isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(movie.isFavorite ? .red : .gray.opacity(0.6))
                                .frame(width: 16, height: 16)
                        }
                    }
                    Spacer()
                }.frame(width: width).padding(12)
            ),
            onTap: { showingSheet = true },
            width: width
        )
        .sheet(isPresented: $showingSheet) {
            let posterURL900: URL? = {
                guard let url = movie.posterURL else { return nil }
                let urlString = url.absoluteString.replacingOccurrences(of: "SX300", with: "SX900")
                return URL(string: urlString)
            }()
            VStack(spacing: 0) {
                AsyncImage(url: posterURL900) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .padding(.bottom, 8)
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                            )
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 30))
                                        .foregroundColor(.orange)
                                    Text("이미지를 불러올 수 없습니다")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            )
                            .frame(height: 300)
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(movie.year)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(movie.type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            onFavoriteToggle(movie)
                            showingSheet = false
                        }) {
                            Text(movie.isFavorite ? "즐겨찾기 제거" : "즐겨찾기")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(movie.isFavorite ? Color.red : Color.blue)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showingSheet = false
                        }) {
                            Text("닫기")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Favorite MovieCard
struct FavoriteMovieCard: View {
    let movie: MovieUIModel
    let onRemove: (MovieUIModel) -> Void
    let width: CGFloat
    @State private var showingSheet = false
    
    var body: some View {
        BaseMovieCard(
            movie: movie,
            icon: nil,
            onTap: { showingSheet = true },
            width: width
        )
        .sheet(isPresented: $showingSheet) {
            let posterURL900: URL? = {
                guard let url = movie.posterURL else { return nil }
                let urlString = url.absoluteString.replacingOccurrences(of: "SX300", with: "SX900")
                return URL(string: urlString)
            }()
            VStack(spacing: 0) {
                AsyncImage(url: posterURL900) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack {
                                    ProgressView()
                                        .scaleEffect(1.5)
                                        .padding(.bottom, 8)
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                }
                            )
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 300)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 30))
                                        .foregroundColor(.orange)
                                    Text("이미지를 불러올 수 없습니다")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            )
                            .frame(height: 300)
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(movie.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text(movie.year)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(movie.type)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(4)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            onRemove(movie)
                            showingSheet = false
                        }) {
                            Text("즐겨찾기 제거")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        
                        Button(action: {
                            showingSheet = false
                        }) {
                            Text("닫기")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Previews
struct MovieCards_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchMovieCard(
                movie: .dummy,
                onFavoriteToggle: { _ in },
                width: 100
            )
            
            FavoriteMovieCard(
                movie: .dummy.with(isFavorite: true),
                onRemove: { _ in },
                width: 100
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

private extension MovieUIModel {
    func with(isFavorite: Bool) -> MovieUIModel {
        var copy = self
        copy.isFavorite = isFavorite
        return copy
    }
} 
