import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage()
    private var task: URLSessionTask?
    
    private var lastCode: String?
    private var activeCode: String?
    private let urlSession = URLSession.shared
    
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
        assert(Thread.isMainThread)
        
        if let currentTask = task {
            if lastCode == code {
                print("OAuth2Service: Duplicate request with same code")
                completion(.failure(AuthServiceError.invalidRequest))
                return
            } else {
                currentTask.cancel()
            }
        } else if lastCode == code {
            print("OAuth2Service: Code wass already used")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Error occured while creating URLRequest")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.task = nil
                self?.lastCode = nil
            }
            
            switch result {
            case .success(let decoded):
                self?.tokenStorage.token = decoded.accessToken
                print("OAuth2Service: Token received successfully")
                completion(.success(decoded.accessToken))
                
            case .failure(let error):
                print("OAuth2Service: Error - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        self.task = task
        task.resume()
    }
}
