import UIKit
import GoogleMobileAds

class PriorityViewController: UIViewController, GADBannerViewDelegate {
    
    @IBOutlet weak var itemOneButton: UIButton!
    @IBOutlet weak var itemTwoButton: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var items = [Item]()
    
    var appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isMatch = false
    var matchCount = 0
    var allMatchCount = 0
    var endIndex = 0
    var beforEndIndex = 0
    
    var itemOneIndex = 0
    var itemTwoIndex = 0
    
    //MARK: 뷰
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //버튼 초기화
        itemOneButton.titleLabel?.lineBreakMode = .byWordWrapping
        itemOneButton.titleLabel?.numberOfLines = 0
        itemOneButton.titleLabel?.textAlignment = .center
        itemTwoButton.titleLabel?.lineBreakMode = .byWordWrapping
        itemTwoButton.titleLabel?.numberOfLines = 0
        itemTwoButton.titleLabel?.textAlignment = .center
        
        if appDelegate.itemArray.count > 1 {
            endIndex = appDelegate.itemArray.endIndex - 1
            beforEndIndex = endIndex - 1
            
            if !isMatch {
                matchCount = appDelegate.itemArray.count - 1
                allMatchCount = matchCount
                
                let itemOne = appDelegate.itemArray[beforEndIndex].title
                itemOneButton.setTitle(itemOne, for: .normal)
                let itemTwo = appDelegate.itemArray[endIndex].title
                itemTwoButton.setTitle(itemTwo, for: .normal)
                
                //인텍스 초기화
                itemOneIndex = beforEndIndex
                itemTwoIndex = endIndex
            }
        } else {
        }
    }
    
    //MARK: 메소드
    func itemHide() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.itemOneButton.alpha = 0
            self.itemTwoButton.alpha = 0
        }, completion: {(completed) in
            self.endIndex = self.appDelegate.itemArray.endIndex - 1
            self.beforEndIndex = self.endIndex - 1
            self.itemOneButton.setTitle(self.appDelegate.itemArray[self.beforEndIndex].title, for: .normal)
            self.itemTwoButton.setTitle(self.appDelegate.itemArray[self.endIndex].title, for: .normal)
        })
        
        self.navigationController?.popViewController(animated: true)
        isMatch = false
    }
    
    func match(item: String) {
        switch item {
        case "One":
            print("one")
            if itemOneIndex < itemTwoIndex {
                if itemOneIndex == 0 {
                    itemOneIndex = beforEndIndex
                    itemTwoIndex = endIndex
                } else {
                    itemTwoIndex = itemOneIndex - 1
                }
            } else {
                let tempItem = appDelegate.itemArray[itemOneIndex]
                appDelegate.itemArray[itemOneIndex] = appDelegate.itemArray[itemTwoIndex]
                appDelegate.itemArray[itemTwoIndex] = tempItem
                
                if itemOneIndex == 1 {
                    itemOneIndex = beforEndIndex
                    itemTwoIndex = endIndex
                } else {
                    itemOneIndex = itemOneIndex - 1
                    itemTwoIndex = itemTwoIndex - 1
                }
            }
        case "Two":
            print("two")
            
            if itemOneIndex < itemTwoIndex {
                let tempItem = appDelegate.itemArray[itemOneIndex]
                appDelegate.itemArray[itemOneIndex] = appDelegate.itemArray[itemTwoIndex]
                appDelegate.itemArray[itemTwoIndex] = tempItem
                
                if itemOneIndex == 0 {
                    itemOneIndex = beforEndIndex
                    itemTwoIndex = endIndex
                } else {
                    itemOneIndex = itemOneIndex - 1
                    itemTwoIndex = itemTwoIndex - 1
                }
            } else {
                if itemOneIndex == 1 {
                    itemOneIndex = beforEndIndex
                    itemTwoIndex = endIndex
                } else {
                    itemOneIndex = itemTwoIndex - 1
                }
            }
        default:
            print("default")
        }
        
        allMatchCount = allMatchCount - 1
        if allMatchCount == 0 {
            matchCount = matchCount - 1
            allMatchCount = matchCount
            
            itemOneIndex = beforEndIndex
            itemTwoIndex = endIndex
        }
        
        //버튼 타이틀 바꾸기
        itemOneButton.setTitle(appDelegate.itemArray[itemOneIndex].title, for: .normal)
        itemTwoButton.setTitle(appDelegate.itemArray[itemTwoIndex].title, for: .normal)
        
        updateCoreData()
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
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
    }
    
    
    //MARK:  액션
    @IBAction func backListView(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func itemOneWin(_ sender: UIButton) {
        match(item: "One")
        
        //버튼클릭시 애니메이션추가
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.itemOneButton.alpha = 0.5
        }, completion: { (completedAnimation) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.itemOneButton.alpha = 1
            }, completion: {(completed) in
                if self.matchCount == 0 {
                    self.itemHide()
                }
            })
        })
        
        let width = self.itemTwoButton.frame.width
        let height = self.itemTwoButton.frame.height
        let x = self.itemTwoButton.frame.minX
        let y = self.itemTwoButton.frame.minY
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.itemTwoButton.titleLabel?.text = ""
            let newX = width / 2
            let newY = y + height / 2
            self.itemTwoButton.frame = CGRect(x: newX, y: newY, width: 0, height: 0)
        }, completion: { (completedAnimation) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.itemTwoButton.frame = CGRect(x: x, y: y, width: width, height: height)
            }, completion: nil)
        })
    }
    
    @IBAction func itemTwoWin(_ sender: UIButton) {
        match(item: "Two")
        
        //버튼클릭시 애니메이션추가
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.itemTwoButton.alpha = 0.5
        }, completion: { (completedAnimation) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.itemTwoButton.alpha = 1
            }, completion: {(completed) in
                if self.matchCount == 0 {
                    self.itemHide()
                }
            })
        })
        
        let width = self.itemOneButton.frame.width
        let height = self.itemOneButton.frame.height
        let x = self.itemOneButton.frame.minX
        let y = self.itemOneButton.frame.minY
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.itemOneButton.titleLabel?.text = ""
            let newX = width / 2
            let newY = y + height / 2
            self.itemOneButton.frame = CGRect(x: newX, y: newY, width: 0, height: 0)
        }, completion: { (completedAnimation) in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.itemOneButton.frame = CGRect(x: x, y: y, width: width, height: height)
            }, completion: {(completed) in
                
            })
        })
    }
}
