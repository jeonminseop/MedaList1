import UIKit

final class HolderViewController: UIViewController {
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var _parent: SettingViewController!
    
    var cropViewController: CropViewController!
    var photoViewController: PhotoViewController!
    
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            for child in childViewControllers {
                if let child = child as? CropViewController {
                    child.addImage(image)
                }
            }
        }
    }
    
    //MARK: 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for child in childViewControllers {
            if let child = child as? CropViewController {
                cropViewController = child
                child._parent = self
            } else if let child = child as? PhotoViewController {
                photoViewController = child
                child._parent = self
            }
        }
        
        //노티피케이션 등록
        NotificationCenter.default.addObserver(self, selector: #selector(saveButtonEnable(notification:)), name: NSNotification.Name(rawValue: "SaveButtonNotification"), object: nil)
        
    }
    
    func saveButtonEnable(notification: NSNotification)  {
        if let noti = notification.object {
            let isEnable = noti as! Bool
            saveButton.isEnabled = isEnable
        }
    }

    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK: 액션
    
    @IBAction func didPressSaveButton(_ sender: AnyObject) {
        navigationController?.dismiss(animated: true, completion: nil)
        let image = topContainer.snapshot()
        _parent.image = image
        _parent = nil
    }
    
    @IBAction func didPressCancleButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
