import UIKit
import GoogleMobileAds

class SettingViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var _parent: HomeViewController!
    var image: UIImage?
    var text: String?
    var keyboardIsShow = false
    
    var textViewFrame: CGRect?
    var bannerViewFrame: CGRect?
    
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        //이미지뷰 제스쳐 사용
        imageView.isUserInteractionEnabled = true
        
        //키보드 위에 툴바생성
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 10))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneButtonImage = UIImage(named: "doneButton")
        let doneButton = UIBarButtonItem(image: doneButtonImage, style: .done, target: self, action: #selector(doneButtonAction))
        doneButton.tintColor = UIColor.init(red: 63/255, green: 63/255, blue: 63/255, alpha: 1)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        
        self.textView.inputAccessoryView = toolbar
        
        //ad
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        //실기테스트
        //        request.testDevices = ["af527d944bd6f29d8fa02eebfb44cb24"]
        
        bannerView.adUnitID = "ca-app-pub-5542661431027733/8629546440"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //네비게이션바 표시
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "Setting"
        
        //화면 초기화
        imageView.image = image
        textView.text = text
        
        self.configureObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        text = textView.text
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK: 값전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination   
        if let dest = dest as? UINavigationController, let holder = dest.topViewController as? HolderViewController {
            holder._parent = self
        }
    }
    
    //MARK: 메소드
    
    //노티피케이션 삭제
    func removeObserver() {
        
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    func getStringMonth(month: Int) -> String {
        let stringMonthArray = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        return stringMonthArray[month - 1]
    }
    
    func getStringWeekday(weekday: Int) -> String {
        let stringWeekdayArray = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return stringWeekdayArray[weekday - 1]
    }
    
    //MARK: 키보드 관련 메소드
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //키보드 노티피케이션
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    //키보드가 나올때 실행
    func keyboardWillShow(notification: Notification?) {
        let userInfo = notification?.userInfo!
        let keyboardScreenEndFrame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        if !keyboardIsShow {
            //텍스트뷰 사이즈 조정
            self.textViewFrame = self.textView.frame
            self.textView.frame = CGRect(x: (self.textViewFrame?.origin.x)!, y: (self.textViewFrame?.origin.y)!, width: (self.textViewFrame?.width)!, height: (self.textViewFrame?.height)! / 1.5)
            
            keyboardIsShow = true
            
            //배너뷰 위치 조정
            self.bannerViewFrame = self.bannerView.frame
            self.bannerView.frame = CGRect(x: (self.bannerViewFrame?.origin.x)!, y: self.textView.frame.origin.y + self.textView.frame.height + 8, width: (self.bannerViewFrame?.width)!, height: (self.bannerViewFrame?.height)!)
        }

            
        let textViewLimit = textView.frame.origin.y + textView.frame.height + 8.0 + 44.0
        let keyboardLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        
        if textViewLimit >= keyboardLimit {
            scrollView.contentOffset.y = textViewLimit - keyboardLimit - 44 + 50
            
            let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!, animations: { () in
                //어둡게함
                self.imageView.alpha = 0.5
            })
            
        }
    }
    
    //키보드가 없어질때 실행
    func keyboardWillHide(notification: Notification?) {
        scrollView.contentOffset.y = 0
        
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            
            //원상복귀
            self.imageView.alpha = 1
            
            //텍스트뷰 사이즈 되돌림
            self.textView.frame = self.textViewFrame!
            self.textView.setContentOffset(CGPoint.zero, animated: false)
            
            //배너뷰 위치 되돌림
            self.bannerView.frame = self.bannerViewFrame!
        })
        
        keyboardIsShow = false
    }
    
    //MARK: 액션
    @IBAction func didPressSaveButton(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
        if let text = textView.text {
            appDelegate.profileText = text
            appDelegate.saveProfileText(result: appDelegate.profileText)
        }
        
        if let image = imageView.image {
            if let imageData = UIImagePNGRepresentation(image) {
                appDelegate.profileImgaeData = imageData as NSData
            }
            appDelegate.saveProfileImageData(result: appDelegate.profileImgaeData)
        }
    }
}
