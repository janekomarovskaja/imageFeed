import Foundation

enum Constants {
    static let accessKey = "-exAa4gZtSkpwsFhbW_ROuyqg_NL-LxG2-VKGoVRiYc"
    static let secretKey = "rmUfWevEhmgM77FU8DoZD0RhlJpElqn4f1Ff5PblC6k"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL? = URL(string: "https://api.unsplash.com")
    static let profileRequestURL: URL? = URL(string: "https://api.unsplash.com/me")
}
