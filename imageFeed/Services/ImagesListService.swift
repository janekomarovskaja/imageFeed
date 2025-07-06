import Foundation
import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    
    private var lastLoadedPage: Int = 0
    private var isLoading: Bool = false
    
    private let session = URLSession.shared
    private let perPage = 10
    
    private init() { }
    
    func clean() {
        photos.removeAll()
    }
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        let nextPage = lastLoadedPage + 1
        
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.isLoading = false }
            
            if let error = error {
                print("ImagesListService: Network error: \(error)")
                return
            }
            
            guard let data = data else {
                print("ImagesListService: Empty response data")
                return
            }
            

            do {
                let photoResults = try JSONDecoder().decode([PhotoResult].self, from: data)
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: newPhotos)
                    self.lastLoadedPage = nextPage
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
                
            } catch {
                print("ImagesListService: Decoding error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(String(describing: OAuth2TokenStorage().token))", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike ? "POST" : "DELETE"

        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let self = self else { return }

            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                let updatedPhoto = self.photos[index]
                self.photos[index] = Photo(
                    id: updatedPhoto.id,
                    size: updatedPhoto.size,
                    createdAt: updatedPhoto.createdAt,
                    isLiked: isLike,
                    thumbImageURL: updatedPhoto.thumbImageURL,
                    largeImageURL: updatedPhoto.largeImageURL,
                    fullImageURL: updatedPhoto.fullImageURL
                )
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Photo not found"])))
                }
            }
        }

        task.resume()
    }

}
