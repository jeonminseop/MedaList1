import UIKit
import GoogleMobileAds

class DetailViewController: UIViewController, GADBannerViewDelegate {

    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var listLabel: UILabel!
    @IBOutlet weak var textView: PlaceHolderTextView!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var alarmButton: UIButton!
    @IBOutlet weak var semikolon: UILabel!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var items = [Item]()

    var medalImage = UIImage()
    var listTitle = String()
    var detail = String()
    var selectedIndex = IndexPath()
    
    var hour = [Int]()
    var minute = [Int]()
    var selectedHour = Int()
    var selectedMinute = Int()
    
    var selectedHourLabel = UILabel()
    var selectedMinuteLabel = UILabel()
    
    //MARK: 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //키보드 위에 툴바생성
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 10))
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        let doneButtonImage = UIImage(named: "doneButton")
        let doneButton = UIBarButtonItem(image: doneButtonImage, style: .done, target: self, action: #selector(doneButtonAction))
        doneButton.tintColor = UIColor.init(red: 63/255, green: 63/255, blue: 63/255, alpha: 1)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        
        self.textView.inputAccessoryView = toolbar
        
        //시간어레이 설정
        for _ in 1 ..< 100 {
            hour += Array(0...23)
        }
        for _ in 0 ... 59 {
            minute += Array(0...59)
        }
        
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
        medalImageView.image = medalImage
        listLabel.text = listTitle
        textView.placeHolder = NSLocalizedString("Enter details.", comment: "") as NSString
        textView.text = detail
        
        timePicker.alpha = 0.0
        textView.alpha = 1.0
        semikolon.alpha = 0.0
        alarmButton.setTitle("ALARM", for: .normal)
    }
    
    //MARK: 메소드
    func doneButtonAction() {
        self.view.endEditing(true)
    }
    
    //업데이트 코어데이트
    func updateCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            items = try context.fetch(Item.fetchRequest())
            for i in 0 ..< items.count {
                let deleteItem = items[i] as Item
                context.delete(deleteItem)
            }
        } catch {
            print("error")
        }
        
        for i in 0 ..< appDelegate.itemArray.count {
            let item = Item(context: context)
            
            item.title = appDelegate.itemArray[i].title
            item.checkImage = appDelegate.itemArray[i].checkImage
            item.detail = appDelegate.itemArray[i].detail
            item.notiSet = appDelegate.itemArray[i].notiSet
            item.hour = appDelegate.itemArray[i].hour
            item.minute = appDelegate.itemArray[i].minute
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }

    //MARK: 엑션
    @IBAction func popListView(_ sender: UIButton) {
        if alarmButton.currentTitle == "SET" || alarmButton.currentTitle == "DELETE" {
            timePicker.alpha = 0.0
            semikolon.alpha = 0.0
            textView.alpha = 1.0
            alarmButton.setTitle("ALARM", for: .normal)
        } else {
            if textView.text == "" {
                appDelegate.itemArray[selectedIndex.row].detail = nil//"Enter details."
            } else {
                appDelegate.itemArray[selectedIndex.row].detail = textView.text
            }
            updateCoreData()
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func alarmSetting(_ sender: UIButton) {
        var hour = appDelegate.itemArray[selectedIndex.row].hour
        var minute = appDelegate.itemArray[selectedIndex.row].minute
        
        print(hour)
        print(minute)
        
        if alarmButton.currentTitle == "ALARM" {
            timePicker.alpha = 1.0
            semikolon.alpha = 1.0
            textView.alpha = 0.0
            if appDelegate.itemArray[selectedIndex.row].notiSet == "UnSet" {
                alarmButton.setTitle("SET", for: .normal)
                
                timePicker.selectRow(24 * 50, inComponent: 0, animated: false)
                timePicker.selectRow(60 * 50, inComponent: 1, animated: false)
            } else {
                alarmButton.setTitle("DELETE", for: .normal)
                
                timePicker.selectRow(24 * 50 + Int(hour), inComponent: 0, animated: false)
                timePicker.selectRow(60 * 50 + Int(minute), inComponent: 1, animated: false)
            }
        } else {
            if alarmButton.currentTitle == "SET" {
                appDelegate.itemArray[selectedIndex.row].notiSet = "Set"
                appDelegate.itemArray[selectedIndex.row].hour = Int16(selectedHour)
                appDelegate.itemArray[selectedIndex.row].minute = Int16(selectedMinute)
                
                hour = appDelegate.itemArray[selectedIndex.row].hour
                minute = appDelegate.itemArray[selectedIndex.row].minute
                appDelegate.notiSet(identifier: listTitle, hour: hour, minute: minute)
            } else if alarmButton.currentTitle == "DELETE" {
                appDelegate.notiDelete(identifier: listTitle)
                appDelegate.itemArray[selectedIndex.row].notiSet = "UnSet"
            }
            updateCoreData()
            
            timePicker.alpha = 0.0
            semikolon.alpha = 0.0
            textView.alpha = 1.0
            alarmButton.setTitle("ALARM", for: .normal)
        }
    }
}

extension DetailViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return minute.count
        } else {
            return hour.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            return self.minute[row] < 10 ? "0" + String(self.minute[row]) : String(self.minute[row])
        } else {
            return self.hour[row] < 10 ? "0" +  String(self.hour[row]) : String(self.hour[row])
        }
    }
}

extension DetailViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            print(self.minute[row])
            selectedMinuteLabel = pickerView.view(forRow: row, forComponent: component) as! UILabel
            pickerView.reloadComponent(component)
            
            selectedMinute = self.minute[row]
        } else {
            print(self.hour[row])
            selectedHourLabel = pickerView.view(forRow: row, forComponent: component) as! UILabel
            pickerView.reloadComponent(component)
            
            selectedHour = self.hour[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 70.0
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if component == 1 {
            let pickerLabel = UILabel()
            let titleData = self.minute[row] < 10 ? "0" + String(self.minute[row]) : String(self.minute[row])
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 60),NSForegroundColorAttributeName:UIColor.lightGray])
            
            pickerLabel.attributedText = myTitle
            pickerLabel.textAlignment = .center
            pickerLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 70)
            
            if let lb = pickerView.view(forRow: row, forComponent: component) as? UILabel{
                self.selectedMinuteLabel = lb
                self.selectedMinuteLabel.textColor = UIColor.init(red: 117/255, green: 196/255, blue: 155/255, alpha: 1)
            }
            
            return pickerLabel
        } else {
            let pickerLabel = UILabel()
            let titleData =  self.hour[row] < 10 ? "0" +  String(self.hour[row]) : String(self.hour[row])
            let myTitle = NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont.boldSystemFont(ofSize: 60),NSForegroundColorAttributeName:UIColor.lightGray])
            
            pickerLabel.attributedText = myTitle
            pickerLabel.textAlignment = .center
            pickerLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 70)
            
            if let lb = pickerView.view(forRow: row, forComponent: component) as? UILabel{
                self.selectedMinuteLabel = lb
                self.selectedMinuteLabel.textColor = UIColor.init(red: 117/255, green: 196/255, blue: 155/255, alpha: 1)
            }
            
            return pickerLabel
        }
    }
}
