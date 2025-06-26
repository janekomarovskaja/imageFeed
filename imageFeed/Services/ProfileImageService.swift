import Foundation

struct UserResult: Codable {
    let profileImage: ProfileImage

    enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }

    struct ProfileImage: Codable {
        let small: String
    }
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name("ProfileImageServiceDidChange")
    static let userInfoKey = "URL"

    private init() {}

    private var currentTask: URLSessionTask?
    private(set) var avatarURL: String?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        currentTask?.cancel()

        guard !username.isEmpty else {
            print("ProfileImageService: Username is empty")
            completion(.failure(NSError(domain: "EmptyUsername", code: 0)))
            return
        }

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("ProfileImageService: Invalid URL for username: \(username)")
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        guard let token = OAuth2TokenStorage().token else {
            print("ProfileImageService: No token available")
            completion(.failure(NSError(domain: "NoToken", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let userResult):
                let smallImageURL = userResult.profileImage.small
                guard !smallImageURL.isEmpty else {
                    print("ProfileImageService: Empty avatar URL for \(username)")
                    completion(.failure(NSError(domain: "EmptyURL", code: 0)))
                    return
                }

                self.avatarURL = smallImageURL

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: [ProfileImageService.userInfoKey: smallImageURL]
                )

                print("ProfileImageService: Successfully fetched avatar URL for \(username)")
                completion(.success(smallImageURL))

            case .failure(let error):
                print("ProfileImageService: Error fetching avatar URL - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }

        currentTask = task
        task.resume()
    }
}
