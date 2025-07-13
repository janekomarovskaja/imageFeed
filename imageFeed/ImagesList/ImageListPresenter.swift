import UIKit
import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var photosCount: Int { get }
    func photo(at index: Int) -> Photo
    func viewDidLoad()
    func fetchNextPage()
    func didTapLike(on cell: ImagesListCell)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private weak var view: ImagesListViewProtocol?
    private let imagesListService = ImagesListService.shared
    
    private var photos: [Photo] = []
    
    var photosCount: Int {
        photos.count
    }
    
    init(view: ImagesListViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(imagesListDidChange),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    func viewDidLoad() {
        fetchNextPage()
    }
    
    func fetchNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func photo(at index: Int) -> Photo {
        photos[index]
    }
    
    func imagesListChanged() {
        imagesListDidChange()
    }
    
    @objc private func imagesListDidChange() {
        let oldCount = photos.count
        let newPhotos = imagesListService.photos
        let newCount = newPhotos.count
        let addedCount = newCount - oldCount
        
        guard addedCount > 0 else { return }
        
        photos = newPhotos
        let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
        
        if oldCount == 0 {
            view?.reloadTable()
        } else {
            view?.insertRows(at: indexPaths)
        }
    }
    
    func didTapLike(on cell: ImagesListCell) {
        guard let indexPath = (view as? UIViewController)?.view.subviews.compactMap({ $0 as? UITableView }).first?.indexPath(for: cell) else {
            return
        }
        
        let photo = photos[indexPath.row]
        let newIsLiked = !photo.isLiked
        
        view?.showLikeLoader()
        
        imagesListService.changeLike(photoId: photo.id, isLike: newIsLiked) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLikeLoader()
                guard let self = self else { return }
                
                switch result {
                case .success:
                    var updatedPhoto = photo
                    updatedPhoto.isLiked = newIsLiked
                    self.photos[indexPath.row] = updatedPhoto
                    self.view?.updateLikeState(for: cell, isLiked: newIsLiked)
                case .failure(let error):
                    print("ImagesListPresenter: Failed to change like: \(error)")
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
