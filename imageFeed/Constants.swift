import Foundation

enum UrlError: Error {
    case invalidBaseURL
}

enum Constants {
    static let accessKey = "-exAa4gZtSkpwsFhbW_ROuyqg_NL-LxG2-VKGoVRiYc"
    static let secretKey = "rmUfWevEhmgM77FU8DoZD0RhlJpElqn4f1Ff5PblC6k"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static func makeBaseURL() throws -> URL {
        guard let defaultBaseURL = URL(string: "https://api.unsplash.com") else {
            throw UrlError.invalidBaseURL
        }
        return defaultBaseURL
    }
}
