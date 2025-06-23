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

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("ProfileImageService: Invalid URL for username: \(username)")
            completion(.failure(NSError(domain: "InvalidURL", code: 0)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let userResult):
                let smallImageURL = userResult.profileImage.small
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
