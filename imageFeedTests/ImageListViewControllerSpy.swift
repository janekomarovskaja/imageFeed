@testable import imageFeed
import Foundation

final class ImageListViewControllerSpy: ImagesListViewProtocol {
    var reloadTableCalled = false
    var insertRowsCalled = false
    var insertRowsIndexPaths: [IndexPath] = []
    
    var showLikeLoaderCalled = false
    var hideLikeLoaderCalled = false
    
    var updateLikeStateCalled = false
    var updatedLikeStateCell: ImagesListCell?
    var updatedLikeStateIsLiked: Bool?
    
    func reloadTable() {
        reloadTableCalled = true
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        insertRowsCalled = true
        insertRowsIndexPaths = indexPaths
    }
    
    func showLikeLoader() {
        showLikeLoaderCalled = true
    }
    
    func hideLikeLoader() {
        hideLikeLoaderCalled = true
    }
    
    func updateLikeState(for cell: ImagesListCell, isLiked: Bool) {
        updateLikeStateCalled = true
        updatedLikeStateCell = cell
        updatedLikeStateIsLiked = isLiked
    }
}
