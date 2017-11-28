import UIKit
import GoogleMobileAds

class ListViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    weak var secureTextAlertAction: DOAlertAction?
    var alertController: DOAlertController!
    weak var textField: UITextField?
    
    var items = [Item]()
    
    //MARK: 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        //코어데이터에서 데이터를 가져옴
        getData()
        
        //테이블뷰 높이 동적할당
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        
        //노티피케이션 등록
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTable(notification:)), name: NSNotification.Name(rawValue: "TableReloadNotification"), object: nil)
        
        //네비게이션바 숨기기
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
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
        tableView.reloadData()
        checkItemMoreTwo()
    }
    
    //MARK: 값전달
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? DetailViewController {
            if let selectedCell = sender as? ListTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCell)
                let selectedList = appDelegate.itemArray[(indexPath?.row)!].title
                let detail = appDelegate.itemArray[(indexPath?.row)!].detail
                detailViewController.listTitle = selectedList!
                if let detailUnrap = detail {
                    detailViewController.detail = detailUnrap
                } else {
                    detailViewController.detail = ""
                }
                detailViewController.selectedIndex = indexPath!
                
                if let medalImage = selectedCell.imageView?.image {
                    detailViewController.medalImage = medalImage
                }
            }
        }
    }
    
    //MARK: 메소드
    //MARK: 코어데이트
    //코어데이터에서 데이터 획득
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        print("getdata")
        do {
            var itemArrayTemp = [ItemStruct]()
            items = try context.fetch(Item.fetchRequest())
            
            for item in items {
                let title = item.title
                let checkImage = item.checkImage
                var notiSet = "UnSet"
                var detail: String?
                let hour = item.hour
                let minute = item.minute

                if let detailUnrap = item.detail {
                    if detailUnrap == "詳細情報を入力してください。" || detailUnrap == "Enter details." || detailUnrap == "상세 정보를 입력하세요." {
                        detail = nil
                    } else {
                        detail = detailUnrap
                    }
                }
                
                if let notiSetUnrap = item.notiSet {
                    notiSet = notiSetUnrap
                }
                
                let itemTemp = ItemStruct(title: title, checkImage: checkImage, detail: detail, notiSet: notiSet, hour: hour, minute: minute)
                itemArrayTemp.append(itemTemp)
            }
            appDelegate.itemArray = itemArrayTemp
        } catch {
            print("error")
        }
    }

    //노티피케이션을 통해 값이 송신되어 오면 등록된 노티피케이션의 셀렉터가 불려오므로 아래 메소드가 사용됨
    func reloadTable(notification: NSNotification)  {
        if let noti = notification.object {
            let title = noti as! String
            let item = ItemStruct(title: title, checkImage: "checkUnSel", detail: nil, notiSet: "UnSet", hour: 0, minute: 0)
            appDelegate.itemArray.append(item)
        }
        
        updateCoreData()
        tableView.reloadData()
        checkItemMoreTwo()
    }
    
    func showSecureTextEntryAlert(editCellIndexPath: IndexPath) {
        alertController = DOAlertController(title: NSLocalizedString("New name", comment: ""), message: nil, preferredStyle: .alert)
        
        //텍스트필드 추가
        alertController.addTextFieldWithConfigurationHandler { textField in
            NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.handleTextFieldTextDidChangeNotification(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
            
            self.textField = textField
            
            //텍스트필드 커스텀
            textField?.placeholder = NSLocalizedString("Enter new name.", comment: "")
            textField?.font = UIFont(name: "HelveticaNeue", size: 15.0)
            textField?.text = self.appDelegate.itemArray[editCellIndexPath.row].title
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
                    if let title = textField.text {
                        //알림이 등록되어 있었다면 기존알림을 없앰
                        if self.appDelegate.itemArray[editCellIndexPath.row].notiSet == "Set" {
                            self.appDelegate.notiDelete(identifier: self.appDelegate.itemArray[editCellIndexPath.row].title!)
                        }
                        
                        self.appDelegate.itemArray[editCellIndexPath.row].title = title
                        
                        //알림이 등록되어 있던 아이탬이면 이름만 바꿔서 다시 알림을 설정함
                        if self.appDelegate.itemArray[editCellIndexPath.row].notiSet == "Set" {
                            self.appDelegate.notiSet(identifier: title, hour: self.appDelegate.itemArray[editCellIndexPath.row].hour, minute: self.appDelegate.itemArray[editCellIndexPath.row].minute)
                        }
                        
                        self.updateCoreData()
                        self.tableView.reloadData()
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
    
    func checkItemMoreTwo() {
        if appDelegate.itemArray.count > 1{
            startButton.isEnabled = true
            startButton.alpha = 1.0
        } else {
            startButton.isEnabled = false
            startButton.alpha = 0.6
        }
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
    
    //MARK: 텍스트필드 델리게이트
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: 액션
    @IBAction func check(_ sender: UIButton) {
        let tag = sender.tag
        if appDelegate.itemArray[tag].checkImage == "checkUnSel" {
            appDelegate.itemArray[tag].checkImage = "check"
        } else {
            appDelegate.itemArray[tag].checkImage = "checkUnSel"
        }
        
        updateCoreData()
        tableView.reloadData()
    }
}

extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.itemArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListTableViewCell
        
        cell.checkBox.tag = indexPath.row
        
        cell.listLabel.text = appDelegate.itemArray[indexPath.row].title
        cell.checkBox.setImage(UIImage(named: appDelegate.itemArray[indexPath.row].checkImage!), for: .normal)
        
        //메달이미지
        if indexPath.row == 0 {
            cell.imageView?.image = UIImage(named: "goldMedal")
        } else if indexPath.row == 1 {
            cell.imageView?.image = UIImage(named: "silverMedal")
        } else if indexPath.row == 2 {
            cell.imageView?.image = UIImage(named: "bronzeMedal")
        } else {
            cell.imageView?.image = UIImage(named: "")
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", comment: "")) { (UITableViewRowAction, IndexPath) in
            print("edit")
            self.showSecureTextEntryAlert(editCellIndexPath: IndexPath)
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "")) { (UITableViewRowAction, IndexPath) in
            print("delete")
            //알림이 등록되어 있었다면 알림도 같이 없애줌
            if self.appDelegate.itemArray[indexPath.row].notiSet == "Set" {
                self.appDelegate.notiDelete(identifier: self.appDelegate.itemArray[indexPath.row].title!)
            }
            
            self.appDelegate.itemArray.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            
            self.updateCoreData()
            tableView.reloadData()
            self.checkItemMoreTwo()
        }
        
        return [deleteAction, editAction]
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.isEditing = editing
    }
}
