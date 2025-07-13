@testable import imageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewProtocol {
    var updateProfileDetailsCalled = false
    var updatedProfile: Profile?

    var updateAvatarImageCalled = false
    var updatedAvatarURL: URL?

    func updateProfileDetails(profile: imageFeed.Profile) {
        updateProfileDetailsCalled = true
        updatedProfile = profile
    }

    func updateAvatarImage(url: URL) {
        updateAvatarImageCalled = true
        updatedAvatarURL = url
    }
}
