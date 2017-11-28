import UIKit
import StoreKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var settingButton: UIButton!
    
    weak var secureTextAlertAction: DOAlertAction?
    var alertController: DOAlertController!
    weak var textField: UITextField?
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        //키보드 노티피케이션 등록
        self.configureObserver()
        
        //접속횟수를 기록함
        if appDelegate.readContectCount() < 6 {
            appDelegate.contectCount = appDelegate.readContectCount() + 1
            appDelegate.saveContectCount(result: appDelegate.contectCount)
        }
        print(appDelegate.readContectCount())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //다섯번째 들어왔을때 리뷰를 의뢰함
        if appDelegate.readContectCount() == 5 {
            showReviewAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        //프로파일 초기화
        let now = NSDate()
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MM"
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
        
        let year = yearFormatter.string(from: now as Date)
        let month = monthFormatter.string(from: now as Date)
        let day = dayFormatter.string(from: now as Date)
        
        let comp = Calendar.Component.weekday
        let weekday = NSCalendar.current.component(comp, from: NSDate() as Date)
        
        yearLabel.text = year
        monthLabel.text = getStringMonth(month: Int(month)!)
        dayLabel.text = day
        weekdayLabel.text = getStringWeekday(weekday: weekday)
        
        if let text = appDelegate.readProfileText() {
            textView.text = text
        } else {
            textView.text = NSLocalizedString("Please enter your favorite sentences.", comment: "")
        }
        
        if let imageData = appDelegate.readProfileImageData() {
            backgroundImageView.image = UIImage(data: imageData as Data)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    //MARK: 값전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //네비게이션바 백버튼 타이틀 커스텀
        if segue.destination is SettingViewController {
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
        
        if let settingViewController = segue.destination as? SettingViewController {
            settingViewController._parent = self
            settingViewController.image = backgroundImageView.image
            settingViewController.text = textView.text
        }
    }
    
    //MARK: 메소드
    //리뷰를 의뢰
    private func showReviewAlert() {
        if #available(iOS 10.3, *) {
            // iOS 10.3이상
            SKStoreReviewController.requestReview()
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/id{com.gmail-jeonminsopdev.MedaList}?action=write-review") {
            // iOS 10.3미만
            showAlertController(url: url)
        }
    }
    
    private func showAlertController(url: URL) {
        let alert = UIAlertController(title: NSLocalizedString("Please review.", comment: ""),
                                      message: NSLocalizedString("Thank you for using MedaList.", comment: ""),
                                      preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(cancelAction)
        
        let reviewAction = UIAlertAction(title: NSLocalizedString("Review", comment: ""),
                                         style: .default,
                                         handler: {
                                            (action:UIAlertAction!) -> Void in
                                            
                                            if #available(iOS 10.0, *) {
                                                UIApplication.shared.open(url, options: [:])
                                            }
                                            else {
                                                UIApplication.shared.openURL(url)
                                            }
                                            
        })
        alert.addAction(reviewAction)
    }
    
    //MARK: 키보드 관련 메소드
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //키보드 노티피케이션
    func configureObserver() {
        
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notification.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    func getStringMonth(month: Int) -> String {
        let stringMonthArray = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
        return stringMonthArray[month - 1]
    }
    
    func getStringWeekday(weekday: Int) -> String {
        let stringWeekdayArray = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        return stringWeekdayArray[weekday - 1]
    }
    
    //키보드가 나올때 실행
    func keyboardWillShow(notification: Notification?) {
        let userInfo = notification?.userInfo!
//        let buttonHeight: CGFloat = 60.0
        let keyboardScreenEndFrame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let myBoundSize: CGSize = UIScreen.main.bounds.size
        
        let keyboardLimit = myBoundSize.height - keyboardScreenEndFrame.size.height
        let containerLimit = containerView.frame.maxY
        
        if containerLimit >= keyboardLimit {
            scrollView.contentOffset.y = containerLimit - keyboardLimit
            
            let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
            UIView.animate(withDuration: duration!, animations: { () in
                //어둡게함
                self.backgroundImageView.alpha = 0.4
                self.yearLabel.alpha = 0.4
                self.monthLabel.alpha = 0.4
                self.dayLabel.alpha = 0.4
                self.textView.alpha = 0.4
                self.settingButton.alpha = 0.4
                self.addButton.alpha = 0.4
            })

        }
    }

    //키보드가 없어질때 실행
    func keyboardWillHide(notification: Notification?) {
        scrollView.contentOffset.y = 0
        
        let duration: TimeInterval? = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!, animations: { () in
            //원상복귀
            self.backgroundImageView.alpha = 0.8
            self.yearLabel.alpha = 1
            self.monthLabel.alpha = 1
            self.dayLabel.alpha = 1
            self.textView.alpha = 0.9
            self.settingButton.alpha = 1
            self.addButton.alpha = 1
        })
    }
    
    func showSecureTextEntryAlert() {
        alertController = DOAlertController(title: NSLocalizedString("New item", comment: ""), message: nil, preferredStyle: .alert)
        
        //텍스트필드 추가
        alertController.addTextFieldWithConfigurationHandler { textField in
            NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.handleTextFieldTextDidChangeNotification(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            
            self.textField = textField
            
            //텍스트필드 커스텀
            textField?.placeholder = NSLocalizedString("Enter new item name.", comment: "")
            textField?.font = UIFont(name: "HelveticaNeue", size: 15.0)
            textField?.textAlignment = .center
        }
        
        //텍스트필드 삭제
        let removeTextFieldObserver: (Void) -> Void = {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidChange, object: self.alertController.textFields!.first)
        }
        
        //알렛액션
        let cancelAction = DOAlertAction(title: "Cancel", style: .cancel) { action in
            print("Cancel")
            removeTextFieldObserver()
        }
        
        let otherAction = DOAlertAction(title: "Save", style: .default) { action in
            let textFields = self.alertController.textFields as? Array<UITextField>
            if textFields != nil {
                for textField: UITextField in textFields! {
                    if let itemName = textField.text {
                        //노티피케이션 경우 itemName을 송신
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TableReloadNotification"), object: itemName)
                    }
                }
            }
            
            removeTextFieldObserver()
        }
        
        otherAction.enabled = false
        
        secureTextAlertAction = otherAction
        
        alertController.addAction(cancelAction)
        alertController.addAction(otherAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func handleTextFieldTextDidChangeNotification(_ notification: Notification) {
        let textField = notification.object as! UITextField
        //글자가 하나이상있어야 세이브버튼 누를수 있게함
        secureTextAlertAction!.enabled = textField.text!.characters.count >= 1
    }
    
    //MARK: 액션
    @IBAction func add(_ sender: Any) {
        showSecureTextEntryAlert()
    }
    
    @IBAction func unwindToTop(segue: UIStoryboardSegue) {
    }
}

extension HomeViewController: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
