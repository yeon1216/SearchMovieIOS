import UIKit

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let imageCache: LRUImageCache

    private init() {
        self.imageCache = LRUImageCache(capacity: 100) // 캐시 용량은 필요에 따라 조절
    }

    func loadImage(from url: URL) async throws -> UIImage {
        let key = url.absoluteString

        if let cachedImage = imageCache.getImage(forKey: key) {
            return cachedImage
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 404 {
                return UIImage(imageLiteralResourceName: "image_not_found")
            } else if !(200...299).contains(httpResponse.statusCode) {
                throw NSError(
                    domain: "ImageError",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "이미지 요청 실패 (code: \(httpResponse.statusCode))"]
                )
            }
        }

        guard let image = UIImage(data: data) else {
            throw NSError(
                domain: "ImageError",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "이미지 변환 실패"]
            )
        }

        imageCache.setImage(image, forKey: key)
        return image
    }

    func clearCache() {
        imageCache.clear()
    }
}

final class LRUImageCache {

    private let capacity: Int
    private var cache: [String: UIImage] = [:]
    private var keys: [String] = []
    private let lock = NSLock()

    init(capacity: Int = 100) {
        self.capacity = max(1, capacity)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clear),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        clear()
    }

    func getImage(forKey key: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }

        guard let image = cache[key] else { return nil }

        if let index = keys.firstIndex(of: key) {
            keys.remove(at: index)
            keys.insert(key, at: 0)
        }

        return image
    }

    func setImage(_ image: UIImage, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }

        if cache[key] != nil {
            if let index = keys.firstIndex(of: key) {
                keys.remove(at: index)
            }
        } else if cache.count >= capacity, let lastKey = keys.last {
            cache.removeValue(forKey: lastKey)
            keys.removeLast()
        }

        cache[key] = image
        keys.insert(key, at: 0)
    }

    @objc func clear() {
        lock.lock()
        defer { lock.unlock() }

        cache.removeAll()
        keys.removeAll()
    }
}

