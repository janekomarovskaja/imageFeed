import Foundation

struct ProfileResult: Codable {
    let id: String
    let username: String
    let firstName: String?
    let lastName: String?
    let bio: String?

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String?
}

final class ProfileService {
    static let shared = ProfileService()

    private var task: URLSessionTask?
    private(set) var profile: Profile?

    init() {}

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let request = makeRequest(token: token) else {
            print("ProfileService: Invalid request")
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "InvalidRequest", code: 0)))
            }
            return
        }

        let session = URLSession.shared

        task = session.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: [profileResult.firstName, profileResult.lastName].compactMap { $0 }.joined(separator: " "),
                    loginName: "@\(profileResult.username)",
                    bio: profileResult.bio
                )

                self.profile = profile
                print("ProfileService: Profile fetched successfully")

                DispatchQueue.main.async {
                    completion(.success(profile))
                }

            case .failure(let error):
                print("ProfileService: Error - \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }

        task?.resume()
    }

    private func makeRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
