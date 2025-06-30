import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    static func show() {
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        ProgressHUD.dismiss()
    }
}
