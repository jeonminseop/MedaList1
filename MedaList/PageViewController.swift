//
//  PageViewController.swift
//  PageView
//
//  Created by 전민섭 on 2017/06/20.
//  Copyright © 2017年 전민섭. All rights reserved.
//
//
//import UIKit
//
//class PageViewController: UIPageViewController {
//    
//    weak var pageViewDelegate: PageViewControllerDelegate?
//    
//    private(set) lazy var orderedViewControllers: [UIViewController] = {
//        return [self.newViewController(name: "List"),
//                self.newViewController(name: "Priority")]
//    }()
//    
//    private func newViewController(name: String) -> UIViewController {
//        return UIStoryboard(name: "Main", bundle: nil) .
//            instantiateViewController(withIdentifier: "\(name)ViewController")
//    }
//    
//    //MARK: 뷰
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        dataSource = self
//        delegate = self
//        
//        if let firstViewController = orderedViewControllers.first {
//            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
//        }
//        pageViewDelegate?.pageViewController(self, didUpdatePageCount: orderedViewControllers.count)
//        
//        //노티피케이션 등록
//        NotificationCenter.default.addObserver(self, selector: #selector(showResult(notification:)), name: NSNotification.Name(rawValue: "ShowResultNotification"), object: nil)
//    }
//    
//    //MARK: 메소드
//    func showResult(notification: NSNotification) {
//        let itemName = notification.object as! String
//        print(itemName)
//        if let firstViewController = orderedViewControllers.first {
//            setViewControllers([firstViewController], direction: .reverse, animated: true, completion: nil)
//            pageViewDelegate?.pageViewController(self, didUpdatePageIndex: 0)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "TableReloadNotification"), object: nil)
//        }
//        
//    }
//}

//extension PageViewController: UIPageViewControllerDataSource {
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
//            return nil
//        }
//        
//        let previousIndex = viewControllerIndex - 1
//        
//        guard previousIndex >= 0 else {
//            return nil
//            //return orderedViewControllers.last
//        }
//        
//        guard orderedViewControllers.count > previousIndex else {
//            return nil
//        }
//        
//        return orderedViewControllers[previousIndex]
//    }
//    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
//            return nil
//        }
//        
//        let nextIndex = viewControllerIndex + 1
//        let orderedViewControllersCount = orderedViewControllers.count
//        
//        guard orderedViewControllersCount != nextIndex else {
//            return nil
//            //return orderedViewControllers.last
//        }
//        
//        guard orderedViewControllersCount > nextIndex else {
//            return nil
//        }
//        
//        return orderedViewControllers[nextIndex]
//    }
//    
//    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
//        return orderedViewControllers.count
//    }
//    
//    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
//        guard let firstViewController = viewControllers?.first, let firstViewControllerIndex = orderedViewControllers.index(of: firstViewController) else {
//            return 0
//        }
//        
//        return firstViewControllerIndex
//    }
//}
//
//extension PageViewController: UIPageViewControllerDelegate {
//    
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController],transitionCompleted completed: Bool) {
//        if let firstViewController = viewControllers?.first,
//            let index = orderedViewControllers.index(of: firstViewController) {
//            pageViewDelegate?.pageViewController(self, didUpdatePageIndex: index)
//        }
//    }
//    
//}
//
//protocol PageViewControllerDelegate: class {
//    func pageViewController(_ pageViewController: PageViewController, didUpdatePageCount count: Int)
//    func pageViewController(_ pageViewController: PageViewController, didUpdatePageIndex index: Int)
//}
