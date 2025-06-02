import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?

    private init() {}

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            let url = URL(string: "https://unsplash.com/oauth/token")
        else {
            return nil
        }
        
        let clientID = Constants.accessKey
        let clientSecret = Constants.secretKey
        let redirectURI = Constants.redirectURI

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let parameters = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "redirect_uri": redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]

        let bodyString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        request.httpBody = bodyString.data(using: .utf8)

        return request
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error occured while creating URLRequest")
            completion(.failure(NetworkError.urlSessionError))
            return
        }

        task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    self?.tokenStorage.token = decoded.accessToken
                    print("200 OK")
                    completion(.success(decoded.accessToken))
                } catch {
                    print("Decoding error")
                    completion(.failure(error))
                }

            case .failure(let error):
                switch error {
                case NetworkError.httpStatusCode(let statusCode):
                    print("HTTP error: code \(statusCode)")
                case NetworkError.urlRequestError(let requestError):
                    print("Network error: \(requestError.localizedDescription)")
                case NetworkError.urlSessionError:
                    print("URLSession error")
                default:
                    print("Other error")
                }
                completion(.failure(error))
            }
        }

        task?.resume()
    }
}
