import Foundation

final class ProfileService {
    static let shared = ProfileService()

    private var task: URLSessionTask?
    private(set) var profile: Profile?

    private init() {}
    
    func clean() {
        profile = nil
    }

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
        guard let url = Constants.profileRequestURL else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
