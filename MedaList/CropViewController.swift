import UIKit

final class CropViewController: UIViewController, FloatingViewLayout, Cropable {
    
    @IBOutlet weak var cropContainerView: UIView!
    
    var _parent: HolderViewController!
    
    var floatingView: UIView {
        return _parent.topContainer
    }
    
    var cropView = UIScrollView()
    var childContainerView = UIView()
    var childView = UIImageView()
    var linesView = LinesView()
    
    var topOffset: CGFloat {
        guard let navBar = navigationController?.navigationBar else {
            return 0
        }
        
        return !navBar.isHidden ? navBar.frame.height : 0
    }
    
    lazy var delegate: CropableScrollViewDelegate<CropViewController> = {
        return CropableScrollViewDelegate(cropable: self)
    }()
    
    var animationCompletion: ((Bool) -> Void)?
    var overlayBlurringView: UIView!
    
    var topConstraint: NSLayoutConstraint {
        return _parent.topConstraint
    }
    
    var draggingZone: DraggingZone = .some(50)
    
    var visibleArea: CGFloat = 50
    
    var previousPoint: CGPoint?
    
    var state: State {
        if topConstraint.constant == 0 {
            return .unfolded
        } else if topConstraint.constant + floatingView.frame.height == visibleArea {
            return .folded
        } else {
            return .moved
        }
    }
    
    var allowPanOutside = false
    
    // MARK: 뷰
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addCropable(to: cropContainerView)
        cropView.delegate = delegate
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateContent()
    }
    
    fileprivate var recognizersAdded = false
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateContent()
        
        if !recognizersAdded {
            recognizersAdded = true
            
            let pan = UIPanGestureRecognizer(target: self, action: #selector(CropViewController.didRecognizeMainPan(_:)))
            _parent.view.addGestureRecognizer(pan)
            pan.delegate = self
            
            let checkPan = UIPanGestureRecognizer(target: self, action: #selector(CropViewController.didRecognizeCheckPan(_:)))
            floatingView.addGestureRecognizer(checkPan)
            checkPan.delegate = self
            
            let tapRec = UITapGestureRecognizer(target: self, action: #selector(CropViewController.didRecognizeTap(_:)))
            floatingView.addGestureRecognizer(tapRec)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: 액션
    
    @IBAction func didRecognizeTap(_ rec: UITapGestureRecognizer) {
        if state == .folded {
            restore(view: floatingView, to: .unfolded, animated: true)
        }
    }
    
    var zooming = false
    var checking = false
    var offset: CGFloat = 0 {
        didSet {
            if offset < 0 && state == .moved {
                offset = 0
            }
        }
    }
    
    @IBAction func didRecognizeMainPan(_ rec: UIPanGestureRecognizer) {
        guard !zooming else { return }
        
        if state == .unfolded {
            allowPanOutside = false
        }
        
        receivePanGesture(recognizer: rec, with: floatingView)
        
        updatePhotoCollectionViewScrolling()
    }
    
    @IBAction func didRecognizeCheckPan(_ rec: UIPanGestureRecognizer) {
        guard !zooming else { return }
        allowPanOutside = true
    }
    
    // MARK: 메소드
    
    func prepareForMovement() {
        updateCropViewScrolling()
    }
    
    func didEndMoving() {
        updateCropViewScrolling()
    }
    
    func updateCropViewScrolling() {
        if state == .moved {
            delegate.isEnabled = false
        } else {
            delegate.isEnabled = true
        }
    }
    
    func updatePhotoCollectionViewScrolling() {
        if state == .moved {
            _parent.photoViewController.collectionView.contentOffset.y = offset
        } else {
            offset = _parent.photoViewController.collectionView.contentOffset.y
        }
    }
        
    func willZoom() {
        zooming = true
    }
    
    func willEndZooming() {
        zooming = false
    }
    
}

extension CropViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
